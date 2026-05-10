import api from './api';
import { EmployeeResponse } from '@/types/employee';
import { Employee } from '@/types/employee';

interface FetchEmployeesParams {
  page?: number;
  per_page?: number;
  country?: string;
  job_title?: string;
  sort_by?: string;
  order?: 'asc' | 'desc';
}

export async function fetchEmployees(
  params: FetchEmployeesParams = {}
): Promise<EmployeeResponse> {
  const response = await api.get('/employees', {
    params,
  });

  return response.data;
}

export async function createEmployee(
  employee: Partial<Employee>
) {
  const response = await api.post('/employees', {
    employee,
  });

  return response.data;
}

export async function updateEmployee(
  id: number,
  employee: Partial<Employee>
) {
  const response = await api.patch(
    `/employees/${id}`,
    {
      employee,
    }
  );

  return response.data;
}

export async function deleteEmployee(id: number) {
  await api.delete(`/employees/${id}`);
}

