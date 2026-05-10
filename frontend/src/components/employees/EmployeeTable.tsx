'use client';

import { DataGrid, GridColDef } from '@mui/x-data-grid';
import Paper from '@mui/material/Paper';
import IconButton from '@mui/material/IconButton';

import EditIcon from '@mui/icons-material/Edit';
import DeleteIcon from '@mui/icons-material/Delete';

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

  onEdit: (employee: Employee) => void;
  onDelete: (employee: Employee) => void;
}

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
  onEdit,
  onDelete
}: Props) {
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
    {
      field: 'actions',
      headerName: 'Actions',
      width: 120,
      sortable: false,
      renderCell: (params) => (
        <>
          <IconButton
            onClick={() => onEdit(params.row)}
          >
            <EditIcon />
          </IconButton>

          <IconButton
            color="error"
            onClick={() => onDelete(params.row)}
          >
            <DeleteIcon />
          </IconButton>
        </>
      ),
    }
  ];

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
