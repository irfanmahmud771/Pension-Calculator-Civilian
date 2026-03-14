-- Add CNIC column to logs table (safe to run multiple times)
ALTER TABLE public.logs
ADD COLUMN IF NOT EXISTS cnic text;

-- Clean up CNIC values before applying constraints
UPDATE public.logs
SET cnic = trim(cnic)
WHERE cnic IS NOT NULL;

-- Optional: enforce CNIC format (#####-#######-#)
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1
    FROM pg_constraint
    WHERE conname = 'logs_cnic_format_chk'
  ) THEN
    ALTER TABLE public.logs
    ADD CONSTRAINT logs_cnic_format_chk
    CHECK (cnic ~ '^\\d{5}-\\d{7}-\\d$');
  END IF;
END $$;

-- Create unique index so upsert(..., { onConflict: 'cnic' }) works
CREATE UNIQUE INDEX IF NOT EXISTS logs_cnic_unique_idx
ON public.logs (cnic);

-- Optional: make CNIC mandatory for all future rows
-- ALTER TABLE public.logs ALTER COLUMN cnic SET NOT NULL;
