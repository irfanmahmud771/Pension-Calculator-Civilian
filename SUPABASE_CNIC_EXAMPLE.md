## Supabase code example for CNIC

Use this in your app after adding the `cnic` column and unique index:

```js
const cnicPattern = /^\d{5}-\d{7}-\d$/;
if (!cnicPattern.test(log_cnic)) {
  throw new Error('Invalid CNIC format');
}

const logEntry = {
  pensioner_name: log_pensioner_name,
  cnic: log_cnic,
  basic_pay: log_basic_pay,
  date_of_birth: log_date_of_birth,
  date_of_joining: log_date_of_joining,
  date_of_retirement: log_date_of_retirement,
  date_of_death: log_date_of_death,
  salary_scale: log_salary_scale,
  gross_pension: log_gross_pension,
  net_pension: log_net_pension,
  family_pension: log_family_pension,
  retirement_type: log_retirement_type
};

const { error } = await supabaseClient
  .from('logs')
  .upsert(logEntry, { onConflict: 'cnic' });

if (error) {
  console.error('Error saving log by CNIC:', error);
}
```
