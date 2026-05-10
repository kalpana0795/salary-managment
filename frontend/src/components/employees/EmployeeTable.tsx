'use client';

import { DataGrid, GridColDef } from '@mui/x-data-grid';
import Paper from '@mui/material/Paper';

import { Employee } from '@/types/employee';

interface Props {
  employees: Employee[];
  loading: boolean;

  sortBy: string;
  sortOrder: 'asc' | 'desc';
  onSortChange: (
    field: string,
    order: 'asc' | 'desc'
  ) => void;

  total: number;
  page: number;
  pageSize: number;
  onPaginationChange: (page: number, pageSize: number) => void;
}

const columns: GridColDef[] = [
  {
    field: 'full_name',
    headerName: 'Name',
    flex: 1,
  },
  {
    field: 'job_title',
    headerName: 'Job Title',
    flex: 1,
  },
  {
    field: 'department',
    headerName: 'Department',
    flex: 1,
  },
  {
    field: 'country',
    headerName: 'Country',
    width: 120,
  },
  {
    field: 'salary',
    headerName: 'Salary',
    width: 140,
    valueGetter: (_, row) =>
      `${row.currency} ${row.salary.toLocaleString()}`,
  },
];

export default function EmployeeTable({
  employees,
  loading,
  sortBy,
  sortOrder,
  onSortChange,
  total,
  page,
  pageSize,
  onPaginationChange,
}: Props) {
  return (
    <Paper sx={{ height: 600, width: '100%' }}>
      <DataGrid
        rows={employees}
        columns={columns}
        loading={loading}
        sortingMode="server"
        rowCount={total}
        paginationMode="server"
        paginationModel={{
          page: page - 1,
          pageSize,
        }}
        onPaginationModelChange={(model) => {
          onPaginationChange(
            model.page + 1,
            model.pageSize
          );
        }}
        pageSizeOptions={[5, 10, 20, 50]}
        onSortModelChange={(model) => {
          if (model.length > 0) {
            onSortChange(
              model[0].field,
              (model[0].sort as 'asc' | 'desc') || 'asc'
            );
          }
        }}
      />
    </Paper>
  );
}
