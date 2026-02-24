-- SMS Campaign Management System Schema
-- Execute this in Supabase SQL Editor

-- 1. 客戶資料表 (Contacts Table)
CREATE TABLE IF NOT EXISTS contacts (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name TEXT,
    phone_number TEXT NOT NULL UNIQUE,
    tags TEXT[], -- 方便分類客人
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 2. SMS 任務表 (SMS Campaigns Table)
CREATE TABLE IF NOT EXISTS sms_campaigns (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    prompt TEXT NOT NULL, -- 用戶輸入的 prompt
    link TEXT,   -- 提供的 URL
    content TEXT, -- DeepSeek 生成的 1500 字初稿
    status TEXT DEFAULT 'draft', -- draft, scheduled, sent, failed
    scheduled_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 3. 發送記錄 (Message Logs - 一對多，記錄每個客人的發送狀態)
CREATE TABLE IF NOT EXISTS message_logs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    campaign_id UUID NOT NULL REFERENCES sms_campaigns(id) ON DELETE CASCADE,
    contact_id UUID NOT NULL REFERENCES contacts(id) ON DELETE CASCADE,
    status TEXT DEFAULT 'pending', -- pending, sent, failed
    sent_at TIMESTAMP WITH TIME ZONE,
    error_message TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create Indexes for better query performance
CREATE INDEX IF NOT EXISTS idx_contacts_phone ON contacts(phone_number);
CREATE INDEX IF NOT EXISTS idx_sms_campaigns_status ON sms_campaigns(status);
CREATE INDEX IF NOT EXISTS idx_sms_campaigns_scheduled_at ON sms_campaigns(scheduled_at);
CREATE INDEX IF NOT EXISTS idx_message_logs_campaign ON message_logs(campaign_id);
CREATE INDEX IF NOT EXISTS idx_message_logs_contact ON message_logs(contact_id);
CREATE INDEX IF NOT EXISTS idx_message_logs_status ON message_logs(status);

-- Enable RLS (Row Level Security) - Optional but recommended
ALTER TABLE contacts ENABLE ROW LEVEL SECURITY;
ALTER TABLE sms_campaigns ENABLE ROW LEVEL SECURITY;
ALTER TABLE message_logs ENABLE ROW LEVEL SECURITY;

-- Create RLS Policies (Allow all access for now - you may want to restrict this later)
CREATE POLICY "Allow all access to contacts" ON contacts FOR ALL USING (true);
CREATE POLICY "Allow all access to sms_campaigns" ON sms_campaigns FOR ALL USING (true);
CREATE POLICY "Allow all access to message_logs" ON message_logs FOR ALL USING (true);
