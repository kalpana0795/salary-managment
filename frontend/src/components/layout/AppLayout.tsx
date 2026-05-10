'use client';

import AppBar from '@mui/material/AppBar';
import Box from '@mui/material/Box';
import Toolbar from '@mui/material/Toolbar';
import Typography from '@mui/material/Typography';
import Container from '@mui/material/Container';
import Stack from '@mui/material/Stack';
import Button from '@mui/material/Button';

import Link from 'next/link';
import { usePathname } from 'next/navigation';

export default function AppLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  const pathname = usePathname();

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
              sx={{
                borderBottom:
                  pathname === '/'
                    ? '2px solid white'
                    : 'none',
                borderRadius: 0,
              }}
            >
              Employees
            </Button>
            <Button
              color="inherit"
              component={Link}
              href="/insights"
              sx={{
                borderBottom:
                  pathname === '/insights'
                    ? '2px solid white'
                    : 'none',
                borderRadius: 0,
              }}
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
