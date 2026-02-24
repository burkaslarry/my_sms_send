'use client';

import React, { useState, useEffect } from 'react';
import Sidebar from '@/components/Sidebar';
import apiClient from '@/lib/api';
import { supabase } from '@/lib/supabase';
import { Send, Copy, Check } from 'lucide-react';
import toast from 'react-hot-toast';

interface Contact {
  id: string;
  name: string;
  phone_number: string;
}

export default function CampaignPage() {
  const [prompt, setPrompt] = useState('');
  const [link, setLink] = useState('');
  const [generatedContent, setGeneratedContent] = useState('');
  const [scheduledAt, setScheduledAt] = useState('');
  const [contacts, setContacts] = useState<Contact[]>([]);
  const [selectedContacts, setSelectedContacts] = useState<Set<string>>(new Set());
  const [loading, setLoading] = useState(false);
  const [copied, setCopied] = useState(false);

  useEffect(() => {
    loadContacts();
  }, []);

  const loadContacts = async () => {
    try {
      const { data } = await supabase.from('contacts').select('id, name, phone_number');
      if (data) {
        setContacts(data);
      }
    } catch (error) {
      console.error('Failed to load contacts:', error);
    }
  };

  const handleGenerateSMS = async () => {
    if (!prompt) {
      toast.error('Please enter a prompt');
      return;
    }

    setLoading(true);
    try {
      const response = await apiClient.post('/generate-sms', {
        prompt,
        link: link || undefined,
      });
      setGeneratedContent(response.data.content);
      toast.success('SMS generated successfully!');
    } catch (error) {
      console.error('Failed to generate SMS:', error);
      toast.error('Failed to generate SMS');
    } finally {
      setLoading(false);
    }
  };

  const handleScheduleSMS = async () => {
    if (!generatedContent) {
      toast.error('Please generate SMS content first');
      return;
    }

    if (!scheduledAt) {
      toast.error('Please select a scheduled time');
      return;
    }

    setLoading(true);
    try {
      const contactIds = selectedContacts.size > 0 ? Array.from(selectedContacts) : undefined;

      await apiClient.post('/schedule-sms', {
        prompt,
        link: link || undefined,
        content: generatedContent,
        scheduled_at: new Date(scheduledAt).toISOString(),
        contact_ids: contactIds,
      });

      toast.success('Campaign scheduled successfully!');
      // Reset form
      setPrompt('');
      setLink('');
      setGeneratedContent('');
      setScheduledAt('');
      setSelectedContacts(new Set());
    } catch (error) {
      console.error('Failed to schedule SMS:', error);
      toast.error('Failed to schedule SMS');
    } finally {
      setLoading(false);
    }
  };

  const handleCopyContent = () => {
    navigator.clipboard.writeText(generatedContent);
    setCopied(true);
    setTimeout(() => setCopied(false), 2000);
  };

  const toggleContactSelection = (contactId: string) => {
    const newSelected = new Set(selectedContacts);
    if (newSelected.has(contactId)) {
      newSelected.delete(contactId);
    } else {
      newSelected.add(contactId);
    }
    setSelectedContacts(newSelected);
  };

  return (
    <div className="flex w-full min-h-screen">
      <Sidebar />

      <main className="flex-1 ml-0 md:ml-64 p-4 md:p-8">
        <div className="max-w-4xl mx-auto">
          <h1 className="text-4xl font-bold text-gray-900 mb-8">New Campaign</h1>

          <div className="space-y-6">
            {/* Prompt Section */}
            <div className="bg-white rounded-lg shadow p-6">
              <h2 className="text-2xl font-bold mb-4">1. Create Prompt</h2>
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">
                  Your Prompt
                </label>
                <textarea
                  value={prompt}
                  onChange={(e) => setPrompt(e.target.value)}
                  placeholder="e.g., Write a promotional message for our summer sale..."
                  className="w-full h-32 px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent resize-none"
                />
              </div>

              <div className="mt-4">
                <label className="block text-sm font-medium text-gray-700 mb-2">
                  Link (Optional)
                </label>
                <input
                  type="url"
                  value={link}
                  onChange={(e) => setLink(e.target.value)}
                  placeholder="https://example.com"
                  className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                />
              </div>

              <button
                onClick={handleGenerateSMS}
                disabled={loading || !prompt}
                className="mt-6 w-full bg-blue-600 text-white py-3 rounded-lg hover:bg-blue-700 disabled:bg-gray-400 transition font-semibold flex items-center justify-center gap-2"
              >
                <Send size={20} />
                {loading ? 'Generating...' : 'Generate with DeepSeek'}
              </button>
            </div>

            {/* Preview Section */}
            {generatedContent && (
              <div className="bg-white rounded-lg shadow p-6">
                <h2 className="text-2xl font-bold mb-4">2. Preview & Edit</h2>
                <div className="relative">
                  <textarea
                    value={generatedContent}
                    onChange={(e) => setGeneratedContent(e.target.value)}
                    className="w-full h-48 px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent resize-none"
                  />
                  <div className="absolute bottom-4 right-4 text-sm text-gray-500">
                    {generatedContent.length}/1500
                  </div>
                </div>

                <button
                  onClick={handleCopyContent}
                  className="mt-4 flex items-center gap-2 px-4 py-2 bg-gray-200 text-gray-700 rounded hover:bg-gray-300 transition"
                >
                  {copied ? <Check size={18} /> : <Copy size={18} />}
                  {copied ? 'Copied!' : 'Copy Content'}
                </button>
              </div>
            )}

            {/* Contact Selection Section */}
            {generatedContent && (
              <div className="bg-white rounded-lg shadow p-6">
                <h2 className="text-2xl font-bold mb-4">3. Select Recipients</h2>
                <p className="text-gray-600 mb-4">
                  {selectedContacts.size > 0
                    ? `Selected ${selectedContacts.size} contact(s)`
                    : 'Select contacts or leave empty to send to all'}
                </p>

                <div className="space-y-2 max-h-64 overflow-y-auto">
                  {contacts.map((contact) => (
                    <label
                      key={contact.id}
                      className="flex items-center p-3 border border-gray-300 rounded-lg hover:bg-gray-50 cursor-pointer"
                    >
                      <input
                        type="checkbox"
                        checked={selectedContacts.has(contact.id)}
                        onChange={() => toggleContactSelection(contact.id)}
                        className="w-4 h-4 text-blue-600 rounded"
                      />
                      <div className="ml-3 flex-1">
                        <div className="font-medium text-gray-900">{contact.name || 'Unnamed'}</div>
                        <div className="text-sm text-gray-500">{contact.phone_number}</div>
                      </div>
                    </label>
                  ))}
                </div>
              </div>
            )}

            {/* Schedule Section */}
            {generatedContent && (
              <div className="bg-white rounded-lg shadow p-6">
                <h2 className="text-2xl font-bold mb-4">4. Schedule Send</h2>
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-2">
                    Schedule Date & Time
                  </label>
                  <input
                    type="datetime-local"
                    value={scheduledAt}
                    onChange={(e) => setScheduledAt(e.target.value)}
                    className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                  />
                </div>

                <button
                  onClick={handleScheduleSMS}
                  disabled={loading || !scheduledAt}
                  className="mt-6 w-full bg-green-600 text-white py-3 rounded-lg hover:bg-green-700 disabled:bg-gray-400 transition font-semibold flex items-center justify-center gap-2"
                >
                  <Check size={20} />
                  {loading ? 'Scheduling...' : 'Confirm Schedule'}
                </button>
              </div>
            )}
          </div>
        </div>
      </main>
    </div>
  );
}
