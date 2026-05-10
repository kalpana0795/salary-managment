import api from './api';

export async function fetchSalarySummary(
  country?: string
) {
  const response = await api.get(
    '/insights/salary',
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
  page = 1,
  perPage = 10,
  country?: string
) {
  const response = await api.get(
    '/insights/outliers',
    {
      params: {
        page,
        per_page: perPage,
        country,
      },
    }
  );

  return response.data;
}
