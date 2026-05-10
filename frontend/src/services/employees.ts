import api from './api';
import { EmployeeResponse } from '@/types/employee';

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
