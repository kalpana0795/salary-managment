'use client';

import Card from '@mui/material/Card';
import CardContent from '@mui/material/CardContent';
import Typography from '@mui/material/Typography';

import Table from '@mui/material/Table';
import TableBody from '@mui/material/TableBody';
import TableCell from '@mui/material/TableCell';
import TableHead from '@mui/material/TableHead';
import TableRow from '@mui/material/TableRow';
import TablePagination from '@mui/material/TablePagination';

interface Props {
  employees: any[];

  page: number;
  rowsPerPage: number;
  total: number;

  onPageChange: (page: number) => void;
}

export default function OutliersTable({
  employees,
  page,
  rowsPerPage,
  total,
  onPageChange
}: Props) {
  return (
    <Card>
      <CardContent>
        <Typography
          variant="h6"
          gutterBottom
        >
          Salary Outliers
        </Typography>

        <Table>
          <TableHead>
            <TableRow>
              <TableCell>Name</TableCell>
              <TableCell>Job Title</TableCell>
              <TableCell>Country</TableCell>
              <TableCell>Salary</TableCell>
            </TableRow>
          </TableHead>

          <TableBody>
            {employees.map((employee) => (
              <TableRow key={employee.id}>
                <TableCell>
                  {employee.full_name}
                </TableCell>

                <TableCell>
                  {employee.job_title}
                </TableCell>

                <TableCell>
                  {employee.country}
                </TableCell>

                <TableCell>
                  {employee.currency}{' '}
                  {employee.salary.toLocaleString()}
                </TableCell>
              </TableRow>
            ))}
          </TableBody>
        </Table>
        <TablePagination
          component="div"
          count={total}
          page={page - 1}
          rowsPerPage={rowsPerPage}
          rowsPerPageOptions={[10]}
          onPageChange={(_, newPage) =>
            onPageChange(newPage + 1)
          }
        />
      </CardContent>
    </Card>
  );
}
