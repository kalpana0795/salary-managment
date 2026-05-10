'use client';

import Stack from '@mui/material/Stack';
import TextField from '@mui/material/TextField';
import MenuItem from '@mui/material/MenuItem';

interface Props {
  country: string;
  jobTitle: string;
  onCountryChange: (value: string) => void;
  onJobTitleChange: (value: string) => void;
}

const countries = [
  '',
  'India',
  'USA',
  'Germany',
  'Canada',
  'UK',
];

export default function EmployeeFilters({
  country,
  jobTitle,
  onCountryChange,
  onJobTitleChange,
}: Props) {
  return (
    <Stack
      direction={{ xs: 'column', md: 'row' }}
      spacing={2}
    >
      <TextField
        select
        label="Country"
        value={country}
        onChange={(e) =>
          onCountryChange(e.target.value)
        }
        sx={{ minWidth: 200 }}
      >
        {countries.map((value) => (
          <MenuItem key={value} value={value}>
            {value || 'All'}
          </MenuItem>
        ))}
      </TextField>

      <TextField
        label="Job Title"
        value={jobTitle}
        onChange={(e) =>
          onJobTitleChange(e.target.value)
        }
      />
    </Stack>
  );
}
