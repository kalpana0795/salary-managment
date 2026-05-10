'use client';

import { useEffect, useState } from 'react';

import Stack from '@mui/material/Stack';
import Typography from '@mui/material/Typography';
import CircularProgress from '@mui/material/CircularProgress';

import AppLayout from '@/components/layout/AppLayout';

import SummaryCards from '@/components/insights/SummaryCards';
import SalaryDistributionChart from '@/components/insights/SalaryDistributionChart';
import OutliersTable from '@/components/insights/OutliersTable';
import InsightsFilters from '@/components/insights/InsightsFilters';

import {
  fetchSalarySummary,
  fetchDistribution,
  fetchOutliers,
} from '@/services/insights';

export default function InsightsPage() {
  const [loading, setLoading] = useState(true);

  const [summary, setSummary] = useState<any>(null);

  const [distribution, setDistribution] =
    useState([]);

  const [outliers, setOutliers] = useState([]);

  const [outlierPage, setOutlierPage] =
    useState(1);

  const [outlierTotal, setOutlierTotal] =
    useState(0);

  const [country, setCountry] =
    useState('');

  const [jobTitle, setJobTitle] =
    useState('');

  useEffect(() => {
    loadInsights();
  }, [outlierPage, country, jobTitle]);

  async function loadInsights() {
    try {
      setLoading(true);

      const [
        summaryData,
        distributionData,
        outliersData,
      ] = await Promise.all([
        fetchSalarySummary(country, jobTitle),
        fetchDistribution(country, jobTitle),
        fetchOutliers(country, jobTitle, outlierPage, 10),
      ]);

      setSummary(summaryData);
      setDistribution(distributionData);
      setOutliers(outliersData.data);
      setOutlierTotal(
        outliersData.meta.total
      );

    } finally {
      setLoading(false);
    }
  }

  if (loading) {
    return (
      <AppLayout>
        <CircularProgress />
      </AppLayout>
    );
  }

  return (
    <AppLayout>
      <Stack spacing={4}>
        <Typography variant="h4">
          Salary Insights
        </Typography>

        <InsightsFilters
          country={country}
          jobTitle={jobTitle}
          onCountryChange={(value) => {
            setCountry(value);
            setOutlierPage(1);
          }}
          onJobTitleChange={(value) => {
            setJobTitle(value);
            setOutlierPage(1);
          }}
        />

        {summary && (
          <SummaryCards summary={summary} />
        )}

        <SalaryDistributionChart
          data={distribution}
        />

        <OutliersTable
          employees={outliers}
          page={outlierPage}
          rowsPerPage={10}
          total={outlierTotal}
          onPageChange={setOutlierPage}
        />
      </Stack>
    </AppLayout>
  );
}
