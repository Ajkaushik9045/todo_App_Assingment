-- Create todos table
CREATE TABLE IF NOT EXISTS todos (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    title TEXT NOT NULL CHECK (char_length(title) >= 3),
    description TEXT DEFAULT '',
    deadline TIMESTAMPTZ NOT NULL,
    is_completed BOOLEAN DEFAULT FALSE,
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create index for better query performance
CREATE INDEX IF NOT EXISTS idx_todos_user_id ON todos(user_id);
CREATE INDEX IF NOT EXISTS idx_todos_deadline ON todos(deadline);
CREATE INDEX IF NOT EXISTS idx_todos_is_completed ON todos(is_completed);

-- Enable Row Level Security (RLS)
ALTER TABLE todos ENABLE ROW LEVEL SECURITY;

-- Create policy to allow users to only access their own todos
CREATE POLICY "Users can only access their own todos" ON todos
    FOR ALL USING (auth.uid() = user_id);

-- Create function to automatically update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Create trigger to automatically update updated_at on row updates
CREATE TRIGGER update_todos_updated_at 
    BEFORE UPDATE ON todos 
    FOR EACH ROW 
    EXECUTE FUNCTION update_updated_at_column();
