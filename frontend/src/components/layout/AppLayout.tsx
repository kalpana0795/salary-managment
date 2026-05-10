'use client';

import AppBar from '@mui/material/AppBar';
import Box from '@mui/material/Box';
import Toolbar from '@mui/material/Toolbar';
import Typography from '@mui/material/Typography';
import Container from '@mui/material/Container';

export default function AppLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <Box>
      <AppBar position="static">
        <Toolbar>
          <Typography variant="h6">
            Salary Management Tool
          </Typography>
        </Toolbar>
      </AppBar>

      <Container sx={{ mt: 4 }}>
        {children}
      </Container>
    </Box>
  );
}
