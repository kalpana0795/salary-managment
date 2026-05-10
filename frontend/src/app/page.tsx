'use client';

import { useEffect, useState } from 'react';

import Typography from '@mui/material/Typography';
import Stack from '@mui/material/Stack';
import CircularProgress from '@mui/material/CircularProgress';
import Alert from '@mui/material/Alert';

import AppLayout from '@/components/layout/AppLayout';
import EmployeeTable from '@/components/employees/EmployeeTable';

import { Employee } from '@/types/employee';
import { fetchEmployees } from '@/services/employees';

export default function HomePage() {
  const [employees, setEmployees] = useState<Employee[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');

  const [page, setPage] = useState(1);
  const [pageSize, setPageSize] = useState(10);

  const [total, setTotal] = useState(0);

  useEffect(() => {
    loadEmployees();
  }, [page, pageSize]);

  async function loadEmployees() {
    try {
      setLoading(true);

      const response = await fetchEmployees({
        page,
        per_page: pageSize,
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
          />
        )}
      </Stack>
    </AppLayout>
  );
}
