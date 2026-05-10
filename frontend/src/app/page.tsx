'use client';

import { useEffect, useState } from 'react';

import Typography from '@mui/material/Typography';
import Stack from '@mui/material/Stack';
import CircularProgress from '@mui/material/CircularProgress';
import Alert from '@mui/material/Alert';
import Button from '@mui/material/Button';

import AppLayout from '@/components/layout/AppLayout';
import EmployeeTable from '@/components/employees/EmployeeTable';
import EmployeeFilters from '@/components/employees/EmployeeFilters';
import EmployeeFormDialog from '@/components/employees/EmployeeFormDialog';
import DeleteEmployeeDialog from '@/components/employees/DeleteEmployeeDialog';

import { Employee } from '@/types/employee';
import { fetchEmployees } from '@/services/employees';
import {
  createEmployee,
  updateEmployee,
  deleteEmployee,
} from '@/services/employees';

export default function HomePage() {
  const [employees, setEmployees] = useState<Employee[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');

  const [country, setCountry] = useState('');
  const [jobTitle, setJobTitle] = useState('');

  const [sortBy, setSortBy] = useState('full_name');

  const [sortOrder, setSortOrder] =
    useState<'asc' | 'desc'>('asc');

  const [page, setPage] = useState(1);
  const [pageSize, setPageSize] = useState(10);

  const [total, setTotal] = useState(0);

  const [dialogOpen, setDialogOpen] =
    useState(false);

  const [deleteDialogOpen, setDeleteDialogOpen] =
    useState(false);

  const [selectedEmployee, setSelectedEmployee] =
    useState<Employee | null>(null);

  const [formErrors, setFormErrors] =
    useState<string[]>([]);

  const [formLoading, setFormLoading] =
    useState(false);

  useEffect(() => {
    loadEmployees();
  }, [page, pageSize, country, jobTitle, sortBy, sortOrder]);

  async function loadEmployees() {
    try {
      setLoading(true);

      const response = await fetchEmployees({
        page,
        per_page: pageSize,
        country,
        job_title: jobTitle,
        sort_by: sortBy,
        order: sortOrder,
      });

      setEmployees(response.data);
      setTotal(response.meta.total);
    } catch {
      setError('Failed to load employees');
    } finally {
      setLoading(false);
    }
  }

  async function handleCreateEmployee(
    payload: Partial<Employee>
  ) {
    try {
      setFormLoading(true);
      setFormErrors([]);

      await createEmployee(payload);

      setDialogOpen(false);

      loadEmployees();
    } catch (errors) {
      setFormErrors(
        Array.isArray(errors)
          ? errors
          : ['Failed to create employee']
      );
    } finally {
      setFormLoading(false);
    }
  }

  async function handleUpdateEmployee(
    payload: Partial<Employee>
  ) {
    if (!selectedEmployee) return;

    try {
      setFormLoading(true);
      setFormErrors([]);

      await updateEmployee(
        selectedEmployee.id,
        payload
      );

      setDialogOpen(false);
      setSelectedEmployee(null);

      loadEmployees();
    } catch (errors) {
      setFormErrors(
        Array.isArray(errors)
          ? errors
          : ['Failed to update employee']
      );
    } finally {
      setFormLoading(false);
    }
  }

  async function handleDeleteEmployee() {
    if (!selectedEmployee) return;

    try {
      await deleteEmployee(selectedEmployee.id);

      setDeleteDialogOpen(false);
      setSelectedEmployee(null);

      loadEmployees();
    } catch {
      setError('Failed to delete employee');
    }
  }

  return (
    <AppLayout>
      <Stack spacing={3}>
        <Typography variant="h4">
          Employees
        </Typography>

        {error && (
          <Alert severity="error">
            {error}
          </Alert>
        )}

        <Button
          variant="contained"
          onClick={() => {
            setSelectedEmployee(null);
            setDialogOpen(true);
          }}
        >
          Add Employee
        </Button>
        <EmployeeFilters
          country={country}
          jobTitle={jobTitle}
          onCountryChange={setCountry}
          onJobTitleChange={setJobTitle}
        />

        {loading ? (
          <CircularProgress />
        ) : (
          <EmployeeTable
            employees={employees}
            loading={loading}
            total={total}
            page={page}
            pageSize={pageSize}
            onPaginationChange={(newPage, newPageSize) => {
              setPage(newPage);
              setPageSize(newPageSize);
            }}
            sortBy={sortBy}
            sortOrder={sortOrder}
            onSortChange={(field, order) => {
              setSortBy(field);
              setSortOrder(order);
            }}
            onEdit={(employee) => {
              setSelectedEmployee(employee);
              setFormErrors([]);
              setDialogOpen(true);
            }}
            onDelete={(employee) => {
              setSelectedEmployee(employee);
              setDeleteDialogOpen(true);
            }}
          />
        )}
      </Stack>
      <EmployeeFormDialog
        open={dialogOpen}
        employee={selectedEmployee}
        errors={formErrors}
        loading={formLoading}
        onClose={() => {
          setDialogOpen(false);
          setFormErrors([]);
          setSelectedEmployee(null);
        }}
        onSubmit={(payload) => {
          if (selectedEmployee) {
            handleUpdateEmployee(payload);
          } else {
            handleCreateEmployee(payload);
          }
        }}
      />

      <DeleteEmployeeDialog
        open={deleteDialogOpen}
        employeeName={
          selectedEmployee?.full_name
        }
        onClose={() => {
          setDeleteDialogOpen(false);
          setFormErrors([]);
          setSelectedEmployee(null);
        }}
        onConfirm={handleDeleteEmployee}
      />
    </AppLayout>
  );
}
