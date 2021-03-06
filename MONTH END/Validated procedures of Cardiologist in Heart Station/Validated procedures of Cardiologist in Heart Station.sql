SELECT
	*
FROM df_browse_validated
WHERE month(charge_date) = @Month
and year(charge_date) = @Year
--charge_date BETWEEN '07-01-2018 00:00:00.000' and '07-31-2018 23:59:59.998'
and costcentre_group_id = '8A6503A8-39EE-49B7-8455-8343F0A4F290'   --Heart Station
and validated = 'yes'
and employee_nr IN
(
'2663',
'3170',
'3037',
'6354',
'4301',
'3449',
'3046',
'2820',
'2686',
'3611',
'3479',
'6380',
'3056',
'8497',
'6288',
'3455',
'4346',
'5841',
'4103',
'2738',
'2855',
'2654',
'6353',
'6352',
'3342',
'8569',
'3620',
'8324',
'8350',
'3584',
'3599',
'3411',
'3013',
'6335',
'3568',
'3474',
'3021',
'9108',
'4563',
'5059'
)
order by validation_id