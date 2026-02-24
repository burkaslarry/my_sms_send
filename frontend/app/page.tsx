'use client';

import React from 'react';
import { useRouter } from 'next/navigation';
import { useEffect } from 'react';

export default function Home() {
  const router = useRouter();

  useEffect(() => {
    // Redirect to contacts page on load
    router.push('/contacts');
  }, [router]);

  return (
    <div className="flex items-center justify-center min-h-screen">
      <div className="text-center">
        <h1 className="text-4xl font-bold text-gray-900 mb-4">SMS Campaign Manager</h1>
        <p className="text-gray-600">Redirecting...</p>
      </div>
    </div>
  );
}
