-- 1. Upgrade the existing Wallets Table
ALTER TABLE wallets
    ADD COLUMN IF NOT EXISTS user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    ADD COLUMN IF NOT EXISTS opening_balance NUMERIC DEFAULT 0.0,
    ADD COLUMN IF NOT EXISTS balance_set_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()),
    ADD COLUMN IF NOT EXISTS icon_code INTEGER,
    ADD COLUMN IF NOT EXISTS is_dark BOOLEAN DEFAULT false;

-- Turn on Row Level Security
ALTER TABLE wallets ENABLE ROW LEVEL SECURITY;

-- Policy: Users can only see and edit their own wallets
DROP POLICY IF EXISTS "Users can manage their own wallets" ON wallets;
CREATE POLICY "Users can manage their own wallets" ON wallets
    FOR ALL USING (auth.uid() = user_id);

-- 2. Ensure transactions table has correct links
ALTER TABLE transactions 
    ADD COLUMN IF NOT EXISTS wallet_id UUID REFERENCES wallets(id) ON DELETE SET NULL,
    ADD COLUMN IF NOT EXISTS user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE;

-- 3. Create a Supabase RPC (SQL Function) to instantly calculate the net balance
CREATE OR REPLACE FUNCTION get_user_net_balance(p_user_id UUID)
RETURNS NUMERIC AS $$
DECLARE
    total_net NUMERIC := 0;
    wallet_record RECORD;
    income_sum NUMERIC;
    expense_sum NUMERIC;
BEGIN
    FOR wallet_record IN SELECT id, opening_balance, balance_set_at FROM wallets WHERE user_id = p_user_id LOOP
        
        -- Get Income for this wallet after the opening balance date
        SELECT COALESCE(SUM(amount), 0) INTO income_sum
        FROM transactions
        WHERE user_id = p_user_id 
          AND type = 'income' 
          AND created_at >= wallet_record.balance_set_at
          AND (wallet_id = wallet_record.id OR wallet_id IS NULL);
          
        -- Get Expenses for this wallet after the opening balance date
        SELECT COALESCE(SUM(amount), 0) INTO expense_sum
        FROM transactions
        WHERE user_id = p_user_id 
          AND type = 'expense' 
          AND created_at >= wallet_record.balance_set_at
          AND (wallet_id = wallet_record.id OR wallet_id IS NULL);
          
        -- Add to total net
        total_net := total_net + wallet_record.opening_balance + income_sum - expense_sum;
        
    END LOOP;
    
    RETURN total_net;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
