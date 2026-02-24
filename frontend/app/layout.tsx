'use client';

import React from 'react';
import { Toaster } from 'react-hot-toast';

interface LayoutProps {
  children: React.ReactNode;
}

export default function RootLayout({ children }: LayoutProps) {
  return (
    <html lang="en">
      <head>
        <title>SMS Campaign Manager</title>
        <meta name="description" content="SMS Campaign Management System" />
        <meta name="viewport" content="width=device-width, initial-scale=1" />
      </head>
      <body>
        <div className="flex">
          {children}
        </div>
        <Toaster position="top-right" />
      </body>
    </html>
  );
}
