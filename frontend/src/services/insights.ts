import api from './api';

export async function fetchSalarySummary(
  country?: string,
  jobTitle?: string
) {
  const response = await api.get(
    '/insights/salary',
    {
      params: {
        country,
        job_title: jobTitle,
      }
    }
  );

  return response.data.data;
}

export async function fetchDistribution(
  country?: string,
  jobTitle?: string
) {
  const response = await api.get(
    '/insights/distribution',
    {
      params: {
        country,
        job_title: jobTitle,
      }
    }
  );

  return response.data.data;
}

export async function fetchOutliers(
  country?: string,
  jobTitle?: string,
  page = 1,
  perPage = 10
) {
  const response = await api.get(
    '/insights/outliers',
    {
      params: {
        page,
        per_page: perPage,
        country,
        job_title: jobTitle
      },
    }
  );

  return response.data;
}
