export interface Employee {
  id: number;
  full_name: string;
  job_title: string;
  country: string;
  salary: number;
  currency: string;
  department: string;
}

export interface EmployeeResponse {
  data: Employee[];
  meta: {
    page: number;
    per_page: number;
    total: number;
  };
}
