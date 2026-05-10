'use client';

import { useEffect, useState } from 'react';

import Typography from '@mui/material/Typography';
import Stack from '@mui/material/Stack';
import CircularProgress from '@mui/material/CircularProgress';
import Alert from '@mui/material/Alert';

import AppLayout from '@/components/layout/AppLayout';
import EmployeeTable from '@/components/employees/EmployeeTable';
import EmployeeFilters from '@/components/employees/EmployeeFilters';

import { Employee } from '@/types/employee';
import { fetchEmployees } from '@/services/employees';

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

        {loading ? (
          <CircularProgress />
        ) : (
          <>
            <EmployeeFilters
              country={country}
              jobTitle={jobTitle}
              onCountryChange={setCountry}
              onJobTitleChange={setJobTitle}
            />
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
            />
          </>
        )}
      </Stack>
    </AppLayout>
  );
}
