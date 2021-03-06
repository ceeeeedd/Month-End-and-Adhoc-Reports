SELECT	*,
	    transaction_date_text = RTRIM(transaction_date_month_name) + '-' + RTRIM(transaction_date_year_rcd)
FROM 
(
	SELECT
			hospital_nr,
			patient_name,
			admission_type,
			admission_type_after_move,
			admitting_doctor,
			bed,
			order_owner,
			order_owner_specialty,
			order_owner_sub_specialty,
			item_group_code,
			item_group_name,
			item_code,
			item_desc,
			item_type_code,
			item_type,
			visit_type_rcd,
			visit_type_rcd_after_move,
			visit_type_category,
			visit_type_after_move_category,
			quantity,
			total_amt,
			service_requestor,
			service_provider,
			service_category =
								CASE
									WHEN service_category IS NULL THEN item_group_name
									ELSE service_category
								END,
			gl_acct_code,
			gl_acct_name,
			transaction_date_time, 
			CONVERT(VARCHAR(20), transaction_date_time,101) AS [Transaction Date],
			--CONVERT(VARCHAR(20), transaction_date_time,108) AS [Transaction Time],
			FORMAT(transaction_date_time,'hh:mm tt') AS [Transaction Time],
			transaction_date_day_rcd = (SELECT
					day_rcd
				FROM rpt_KHM_day_ref WITH (NOLOCK)
				WHERE day_rcd = DAY(transaction_date_time)),
			transaction_date_month_rcd = (SELECT
					month_rcd
				FROM rpt_KHM_month_ref WITH (NOLOCK)
				WHERE month_rcd = MONTH(transaction_date_time)),
			transaction_date_month_name = (SELECT
					name
				FROM rpt_KHM_month_ref WITH (NOLOCK)
				WHERE month_rcd = MONTH(transaction_date_time)),
			transaction_date_year_rcd = YEAR(transaction_date_time),
			transaction_type,
			transaction_by,
			current_diagnosis = (SELECT TOP 1
					diagnosis
				FROM HISReport.dbo.ref_patient_diagnosis WITH (NOLOCK)
				WHERE patient_visit_id = DRD.patient_visit_id
				AND current_visit_diagnosis_flag = 1
				ORDER BY recorded_at_date_time DESC),
			admitting_diagnosis = (SELECT TOP 1
					diagnosis
				FROM HISReport.dbo.ref_patient_diagnosis WITH (NOLOCK)
				WHERE patient_visit_id = DRD.patient_visit_id
				AND diagnosis_type_rcd = 'ADM'
				ORDER BY recorded_at_date_time DESC),
			discharge_diagnosis = (SELECT TOP 1
					diagnosis
				FROM HISReport.dbo.ref_patient_diagnosis WITH (NOLOCK)
				WHERE patient_visit_id = DRD.patient_visit_id
				AND diagnosis_type_rcd = 'DIS'
				ORDER BY recorded_at_date_time DESC)
		FROM rpt_daily_revenue_detailed_temp DRD WITH (NOLOCK)
) [rpt_daily_revenue_detailed_all]
WHERE MONTH(transaction_date_time) >= 1 and MONTH(transaction_date_time) <= 1
       AND YEAR(transaction_date_time) = 2018
	   AND item_type_code = 'SRV'
	   and rpt_daily_revenue_detailed_all.service_requestor = 'Center For Executive Health'
ORDER BY rpt_daily_revenue_detailed_all.transaction_date_time, item_type DESC, item_group_name, item_desc, transaction_type