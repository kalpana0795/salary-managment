'use client';

import AppBar from '@mui/material/AppBar';
import Box from '@mui/material/Box';
import Toolbar from '@mui/material/Toolbar';
import Typography from '@mui/material/Typography';
import Container from '@mui/material/Container';
import Stack from '@mui/material/Stack';
import Button from '@mui/material/Button';

import Link from 'next/link'; 

export default function AppLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <Box>
      <AppBar position="static">
      <Toolbar
        sx={{
          display: 'flex',
          justifyContent: 'space-between',
        }}
      >
        <Typography variant="h6">
          Salary Management Tool
        </Typography>

        <Stack direction="row" spacing={2}>
          <Button
            color="inherit"
            component={Link}
            href="/"
          >
            Employees
          </Button>

          <Button
            color="inherit"
            component={Link}
            href="/insights"
          >
            Insights
          </Button>
        </Stack>
      </Toolbar>
      </AppBar>

      <Container sx={{ mt: 4 }}>
        {children}
      </Container>
    </Box>
  );
}
