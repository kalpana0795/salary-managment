'use client';

import Grid from '@mui/material/Grid';
import Card from '@mui/material/Card';
import CardContent from '@mui/material/CardContent';
import Typography from '@mui/material/Typography';

interface Props {
  summary: {
    min_salary: number;
    max_salary: number;
    avg_salary: number;
    employee_count: number;
  };
}

function SummaryCard({
  title,
  value,
}: {
  title: string;
  value: string | number;
}) {
  return (
    <Card>
      <CardContent>
        <Typography
          color="text.secondary"
          gutterBottom
        >
          {title}
        </Typography>

        <Typography variant="h5">
          {value}
        </Typography>
      </CardContent>
    </Card>
  );
}

export default function SummaryCards({
  summary,
}: Props) {
  return (
    <Grid container spacing={2}>
      <Grid size={{ xs: 12, md: 3 }}>
        <SummaryCard
          title="Employees"
          value={summary.employee_count}
        />
      </Grid>

      <Grid size={{ xs: 12, md: 3 }}>
        <SummaryCard
          title="Average Salary"
          value={`$${Math.round(
            summary.avg_salary
          ).toLocaleString()}`}
        />
      </Grid>

      <Grid size={{ xs: 12, md: 3 }}>
        <SummaryCard
          title="Minimum Salary"
          value={`$${summary.min_salary.toLocaleString()}`}
        />
      </Grid>

      <Grid size={{ xs: 12, md: 3 }}>
        <SummaryCard
          title="Maximum Salary"
          value={`$${summary.max_salary.toLocaleString()}`}
        />
      </Grid>
    </Grid>
  );
}
