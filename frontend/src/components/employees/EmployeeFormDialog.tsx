'use client';

import { useEffect, useState } from 'react';

import Dialog from '@mui/material/Dialog';
import DialogTitle from '@mui/material/DialogTitle';
import DialogContent from '@mui/material/DialogContent';
import DialogActions from '@mui/material/DialogActions';
import Alert from '@mui/material/Alert';

import Button from '@mui/material/Button';
import Stack from '@mui/material/Stack';
import TextField from '@mui/material/TextField';

import { Employee } from '@/types/employee';

interface Props {
  open: boolean;
  employee?: Employee | null;
  errors?: string[];
  loading?: boolean;
  onClose: () => void;
  onSubmit: (payload: Partial<Employee>) => void;
}

export default function EmployeeFormDialog({
  open,
  employee,
  errors,
  loading,
  onClose,
  onSubmit,
}: Props) {
  const [form, setForm] = useState({
    full_name: '',
    job_title: '',
    country: '',
    salary: '',
    currency: '',
    department: '',
  });

  useEffect(() => {
    if (employee) {
      setForm({
        full_name: employee.full_name,
        job_title: employee.job_title,
        country: employee.country,
        salary: String(employee.salary),
        currency: employee.currency,
        department: employee.department,
      });
    } else {
      setForm({
        full_name: '',
        job_title: '',
        country: '',
        salary: '',
        currency: '',
        department: '',
      });
    }
  }, [employee]);

  function handleChange(
    field: string,
    value: string
  ) {
    setForm((prev) => ({
      ...prev,
      [field]: value,
    }));
  }

  function handleSubmit() {
    onSubmit({
      ...form,
      salary: Number(form.salary),
    });
  }

  return (
    <Dialog open={open} onClose={onClose} fullWidth>
      <DialogTitle>
        {employee ? 'Edit Employee' : 'Add Employee'}
      </DialogTitle>

      <DialogContent>
        <Stack spacing={2} sx={{ mt: 1 }}>
          {errors && errors.length > 0 && (
            <Alert severity="error">
              <ul style={{ margin: 0, paddingLeft: 20 }}>
                {errors.map((error) => (
                  <li key={error}>{error}</li>
                ))}
              </ul>
            </Alert>
          )}

          <TextField
            label="Full Name"
            value={form.full_name}
            onChange={(e) =>
              handleChange(
                'full_name',
                e.target.value
              )
            }
          />

          <TextField
            label="Job Title"
            value={form.job_title}
            onChange={(e) =>
              handleChange(
                'job_title',
                e.target.value
              )
            }
          />

          <TextField
            label="Country"
            value={form.country}
            onChange={(e) =>
              handleChange(
                'country',
                e.target.value
              )
            }
          />

          <TextField
            label="Salary"
            type="number"
            value={form.salary}
            onChange={(e) =>
              handleChange(
                'salary',
                e.target.value
              )
            }
          />

          <TextField
            label="Currency"
            value={form.currency}
            onChange={(e) =>
              handleChange(
                'currency',
                e.target.value
              )
            }
          />

          <TextField
            label="Department"
            value={form.department}
            onChange={(e) =>
              handleChange(
                'department',
                e.target.value
              )
            }
          />
        </Stack>
      </DialogContent>

      <DialogActions>
        <Button onClick={onClose}>
          Cancel
        </Button>

        <Button
          variant="contained"
          onClick={handleSubmit}
          disabled={loading}
        >
          {loading ? 'Saving...' : 'Save'}
        </Button>
      </DialogActions>
    </Dialog>
  );
}
