import api from './api';

export async function fetchSalarySummary(
  country?: string
) {
  const response = await api.get(
    '/insights/salary-summary',
    {
      params: { country },
    }
  );

  return response.data.data;
}

export async function fetchDistribution(
  country?: string
) {
  const response = await api.get(
    '/insights/distribution',
    {
      params: { country },
    }
  );

  return response.data.data;
}

export async function fetchOutliers(
  country?: string
) {
  const response = await api.get(
    '/insights/outliers',
    {
      params: { country },
    }
  );

  return response.data.data;
}
