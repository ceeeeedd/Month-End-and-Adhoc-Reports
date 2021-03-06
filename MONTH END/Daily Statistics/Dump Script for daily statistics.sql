------(OrionMirror > OrionSnapshotDaily)
-----AmalgaPROD

BEGIN TRAN

	DECLARE @date1 DATETIME
	DECLARE @date2 DATETIME

	--SET @date1 = rtrim(convert(char,month(getdate() - 1))) + '/' + rtrim(convert(char,day(getdate() - 1))) + '/' + rtrim(convert(char,year(getdate() - 1))) + ' ' + '00:00:00.000' 
	--SET @date2 = rtrim(convert(char,month(getdate() - 1))) + '/' + rtrim(convert(char,day(getdate() - 1))) + '/' + rtrim(convert(char,year(getdate() - 1))) + ' ' + '23:59:59.998'
	
	
	SET @date1 = '05/01/2018 00:00:00.000' 
	SET @date2 = '05/31/2018 23:59:59.998'
	
    select * from HISReport.dbo.rpt_daily_revenue_detailed_temp where transaction_date_time between @date1 AND @date2

	INSERT INTO 
		HISReport.dbo.rpt_daily_revenue_detailed_temp (
			charge_detail_id
			,patient_visit_id
			,hospital_nr
			,patient_name
			,admission_type
			,admission_type_after_move
			,admitting_doctor
			,order_owner
			,order_owner_specialty
			,service_category
			,main_item_group_code
			,main_item_group_name
			,item_group_code
			,item_group_name
			,item_code
			,item_desc
			,item_type_code
			,item_type
			,quantity
			,total_amt
			,transaction_date_time
			,transaction_type
			,transaction_by
			,service_requestor
			,service_provider
			,gl_acct_code
			,gl_acct_name
			,visit_type_rcd
			,visit_type_rcd_after_move
			,bed
		)
	SELECT
		charge_detail_id
		,patient_visit_id
		,upi
		,patient_name
		,admission_type
		,admission_type_after_move
		,admitting_doctor
		,order_owner = (SELECT CASE WHEN charge_session_id is null 
							THEN (SELECT display_name_l FROM AmalgaPROD.dbo.employee_formatted_name_iview WHERE person_id = RDRCD.caregiver_employee_id)
							ELSE CASE WHEN (SELECT DISTINCT lab_service_request_id FROM AmalgaPROD.dbo.lab_work_order_nl_view WHERE charge_session_id = RDRCD.charge_session_id) IS NOT NULL
										THEN (SELECT display_name_l FROM AmalgaPROD.dbo.employee_formatted_name_iview WHERE person_id = (SELECT requesting_employee_id FROM AmalgaPROD.dbo.lab_service_request_nl_view WHERE lab_service_request_id = (SELECT DISTINCT lab_service_request_id FROM AmalgaPROD.dbo.lab_work_order_nl_view WHERE charge_session_id = RDRCD.charge_session_id))) --LABORATORY
										ELSE CASE WHEN (SELECT requesting_employee_id FROM AmalgaPROD.dbo.radiology_imaging_service_request_nl_view WHERE charge_session_id = RDRCD.charge_session_id) IS NOT NULL
												THEN (SELECT display_name_l FROM AmalgaPROD.dbo.person_formatted_name_iview_nl_view WHERE person_id = (SELECT requesting_employee_id FROM AmalgaPROD.dbo.radiology_imaging_service_request_nl_view WHERE charge_session_id = RDRCD.charge_session_id)) --RADIOLOGY
												ELSE (SELECT display_name_l FROM AmalgaPROD.dbo.person_formatted_name_iview_nl_view WHERE person_id = (SELECT requesting_employee_id FROM AmalgaPROD.dbo.generic_order_service_request_nl_view WHERE generic_order_service_request_id = (SELECT DISTINCT generic_order_service_request_id FROM AmalgaPROD.dbo.generic_order_item_nl_view WHERE generic_order_item_id = RDRCD.charge_session_id))) --GENERIC
											END
								END
						END)
		,order_owner_specialty = (SELECT CASE WHEN charge_session_id is null 
							THEN (SELECT specialty FROM HISViews.dbo.CUBE_vw_employee_specialty WHERE employee_id = RDRCD.caregiver_employee_id AND seq_num = 0)
							ELSE CASE WHEN (SELECT DISTINCT lab_service_request_id FROM AmalgaPROD.dbo.lab_work_order_nl_view WHERE charge_session_id = RDRCD.charge_session_id) IS NOT NULL
										THEN (SELECT specialty FROM HISViews.dbo.CUBE_vw_employee_specialty WHERE employee_id = (SELECT requesting_employee_id FROM AmalgaPROD.dbo.lab_service_request_nl_view WHERE lab_service_request_id = (SELECT DISTINCT lab_service_request_id FROM AmalgaPROD.dbo.lab_work_order_nl_view WHERE charge_session_id = RDRCD.charge_session_id)) AND seq_num = 0) --LABORATORY
										ELSE CASE WHEN (SELECT requesting_employee_id FROM AmalgaPROD.dbo.radiology_imaging_service_request_nl_view WHERE charge_session_id = RDRCD.charge_session_id) IS NOT NULL
												THEN (SELECT specialty FROM HISViews.dbo.CUBE_vw_employee_specialty WHERE employee_id = (SELECT requesting_employee_id FROM AmalgaPROD.dbo.radiology_imaging_service_request_nl_view WHERE charge_session_id = RDRCD.charge_session_id)  AND seq_num = 0) --RADIOLOGY
												ELSE (SELECT specialty FROM HISViews.dbo.CUBE_vw_employee_specialty WHERE employee_id = (SELECT requesting_employee_id FROM AmalgaPROD.dbo.generic_order_service_request_nl_view WHERE generic_order_service_request_id = (SELECT DISTINCT generic_order_service_request_id FROM AmalgaPROD.dbo.generic_order_item_nl_view WHERE generic_order_item_id = RDRCD.charge_session_id)) AND seq_num = 0) --GENERIC
											END
								END
						END)
		,service_category = CASE WHEN (SELECT TOP 1 item_id FROM AmalgaPROD.dbo.lab_orderable_ref_nl_view WHERE item_id = RDRCD.item_id) IS NOT NULL
								THEN (SELECT name_l FROM AmalgaPROD.dbo.service_category_ref_nl_view WHERE service_category_rcd = (SELECT TOP 1 service_category_rcd FROM AmalgaPROD.dbo.lab_orderable_ref_nl_view WHERE item_id = RDRCD.item_id ORDER BY lu_updated DESC)) --LABORATORY
								ELSE CASE WHEN (SELECT TOP 1 radiology_procedure_type_rid FROM AmalgaPROD.dbo.radiology_procedure_type_service_item WHERE acquisition_service_item_id = RDRCD.item_id) IS NOT NULL
										THEN (SELECT name_l FROM AmalgaPROD.dbo.service_category_ref_nl_view WHERE service_category_rcd = (SELECT TOP 1
																																						RPTR.service_category_rcd
																																					FROM
																																						AmalgaPROD.dbo.radiology_procedure_type_ref_nl_view RPTR 
																																					INNER JOIN
																																						AmalgaPROD.dbo.radiology_procedure_type_service_item RPTSI ON RPTR.radiology_procedure_type_rid = RPTSI.radiology_procedure_type_rid 
																																					WHERE
																																						RPTSI.acquisition_service_item_id = RDRCD.item_id
																																					AND
																																						RPTR.deleted_date_time IS NULL
																																					ORDER BY
																																						RPTR.lu_updated DESC)) --RADIOLOGY
											
										ELSE (SELECT name_l FROM AmalgaPROD.dbo.service_category_ref_nl_view WHERE service_category_rcd = (SELECT TOP 1 service_category_rcd FROM AmalgaPROD.dbo.service_code_ref_nl_view WHERE item_id = RDRCD.item_id ORDER BY lu_updated DESC)) --OTHER ANCILLARY
									END
							END
		,main_item_group_code = (SELECT main_item_group_code FROM HISViews.dbo.GEN_vw_parent_item_group WHERE item_id = RDRCD.item_id AND active_flag = 1)
		,main_item_group_name = (SELECT main_item_group_desc FROM HISViews.dbo.GEN_vw_parent_item_group WHERE item_id = RDRCD.item_id AND active_flag = 1)
		,item_group_code
		,item_group_name
		,item_code
		,item_desc
		,item_type_rcd
		,item_type_name
		,qty
		,total_amount
		,transaction_date_time
		,transaction_type
		,transaction_by
		,service_requestor
		,service_provider
		,gl_acct_code_code
		,gl_acct_name
		,visit_type_rcd
		,visit_type_rcd_after_move
		,bed
	FROM
		HISViews.dbo.RPT_vw_daily_revenue_charges_detailed RDRCD
	WHERE
		transaction_date_time between @date1 and @date2
	AND
		service_provider IN (SELECT DISTINCT name_l FROM HISReport.dbo.ref_costcentre_daily_revenue_detailed WHERE active_flag = 1)
	AND 
		item_type_rcd IN ('SRV', 'INV')
	
	INSERT INTO 
		HISReport.dbo.rpt_daily_revenue_detailed_temp (
			charge_detail_id
			,patient_visit_id
			,hospital_nr
			,patient_name
			,admission_type
			,admission_type_after_move
			,admitting_doctor
			,order_owner
			,order_owner_specialty
			,service_category
			,main_item_group_code
			,main_item_group_name
			,item_group_code
			,item_group_name
			,item_code
			,item_desc
			,item_type_code
			,item_type
			,quantity
			,total_amt
			,transaction_date_time
			,transaction_type
			,transaction_by
			,service_requestor
			,service_provider
			,gl_acct_code
			,gl_acct_name
			,visit_type_rcd
			,visit_type_rcd_after_move
			,bed
		)
	SELECT
		charge_detail_id
		,patient_visit_id
		,upi
		,patient_name
		,admission_type
		,admission_type_after_move
		,admitting_doctor
		,order_owner = (SELECT CASE WHEN charge_session_id is null 
							THEN (SELECT display_name_l FROM AmalgaPROD.dbo.employee_formatted_name_iview WHERE person_id = RDRCD.caregiver_employee_id)
							ELSE CASE WHEN (SELECT DISTINCT lab_service_request_id FROM AmalgaPROD.dbo.lab_work_order_nl_view WHERE charge_session_id = RDRCD.charge_session_id) IS NOT NULL
										THEN (SELECT display_name_l FROM AmalgaPROD.dbo.employee_formatted_name_iview WHERE person_id = (SELECT requesting_employee_id FROM AmalgaPROD.dbo.lab_service_request_nl_view WHERE lab_service_request_id = (SELECT DISTINCT lab_service_request_id FROM AmalgaPROD.dbo.lab_work_order_nl_view WHERE charge_session_id = RDRCD.charge_session_id))) --LABORATORY
										ELSE CASE WHEN (SELECT requesting_employee_id FROM AmalgaPROD.dbo.radiology_imaging_service_request_nl_view WHERE charge_session_id = RDRCD.charge_session_id) IS NOT NULL
												THEN (SELECT display_name_l FROM AmalgaPROD.dbo.person_formatted_name_iview_nl_view WHERE person_id = (SELECT requesting_employee_id FROM AmalgaPROD.dbo.radiology_imaging_service_request_nl_view WHERE charge_session_id = RDRCD.charge_session_id)) --RADIOLOGY
												ELSE (SELECT display_name_l FROM AmalgaPROD.dbo.person_formatted_name_iview_nl_view WHERE person_id = (SELECT requesting_employee_id FROM AmalgaPROD.dbo.generic_order_service_request_nl_view WHERE generic_order_service_request_id = (SELECT DISTINCT generic_order_service_request_id FROM AmalgaPROD.dbo.generic_order_item_nl_view WHERE generic_order_item_id = RDRCD.charge_session_id))) --GENERIC
											END
								END
						END)
		,order_owner_specialty = (SELECT CASE WHEN charge_session_id is null 
							THEN (SELECT specialty FROM HISViews.dbo.CUBE_vw_employee_specialty WHERE employee_id = RDRCD.caregiver_employee_id AND seq_num = 0)
							ELSE CASE WHEN (SELECT DISTINCT lab_service_request_id FROM AmalgaPROD.dbo.lab_work_order_nl_view WHERE charge_session_id = RDRCD.charge_session_id) IS NOT NULL
										THEN (SELECT specialty FROM HISViews.dbo.CUBE_vw_employee_specialty WHERE employee_id = (SELECT requesting_employee_id FROM AmalgaPROD.dbo.lab_service_request_nl_view WHERE lab_service_request_id = (SELECT DISTINCT lab_service_request_id FROM AmalgaPROD.dbo.lab_work_order_nl_view WHERE charge_session_id = RDRCD.charge_session_id)) AND seq_num = 0) --LABORATORY
										ELSE CASE WHEN (SELECT requesting_employee_id FROM AmalgaPROD.dbo.radiology_imaging_service_request_nl_view WHERE charge_session_id = RDRCD.charge_session_id) IS NOT NULL
												THEN (SELECT specialty FROM HISViews.dbo.CUBE_vw_employee_specialty WHERE employee_id = (SELECT requesting_employee_id FROM AmalgaPROD.dbo.radiology_imaging_service_request_nl_view WHERE charge_session_id = RDRCD.charge_session_id)  AND seq_num = 0) --RADIOLOGY
												ELSE (SELECT specialty FROM HISViews.dbo.CUBE_vw_employee_specialty WHERE employee_id = (SELECT requesting_employee_id FROM AmalgaPROD.dbo.generic_order_service_request_nl_view WHERE generic_order_service_request_id = (SELECT DISTINCT generic_order_service_request_id FROM AmalgaPROD.dbo.generic_order_item_nl_view WHERE generic_order_item_id = RDRCD.charge_session_id)) AND seq_num = 0) --GENERIC
											END
								END
						END)
		,service_category = CASE WHEN (SELECT TOP 1 item_id FROM AmalgaPROD.dbo.lab_orderable_ref_nl_view WHERE item_id = RDRCD.item_id) IS NOT NULL
								THEN (SELECT name_l FROM AmalgaPROD.dbo.service_category_ref_nl_view WHERE service_category_rcd = (SELECT TOP 1 service_category_rcd FROM AmalgaPROD.dbo.lab_orderable_ref_nl_view WHERE item_id = RDRCD.item_id ORDER BY lu_updated DESC)) --LABORATORY
								ELSE CASE WHEN (SELECT TOP 1 radiology_procedure_type_rid FROM AmalgaPROD.dbo.radiology_procedure_type_service_item WHERE acquisition_service_item_id = RDRCD.item_id) IS NOT NULL
										THEN (SELECT name_l FROM AmalgaPROD.dbo.service_category_ref_nl_view WHERE service_category_rcd = (SELECT TOP 1
																																						RPTR.service_category_rcd
																																					FROM
																																						AmalgaPROD.dbo.radiology_procedure_type_ref_nl_view RPTR 
																																					INNER JOIN
																																						AmalgaPROD.dbo.radiology_procedure_type_service_item RPTSI ON RPTR.radiology_procedure_type_rid = RPTSI.radiology_procedure_type_rid 
																																					WHERE
																																						RPTSI.acquisition_service_item_id = RDRCD.item_id
																																					AND
																																						RPTR.deleted_date_time IS NULL
																																					ORDER BY
																																						RPTR.lu_updated DESC)) --RADIOLOGY
											
										ELSE (SELECT name_l FROM AmalgaPROD.dbo.service_category_ref_nl_view WHERE service_category_rcd = (SELECT TOP 1 service_category_rcd FROM AmalgaPROD.dbo.service_code_ref_nl_view WHERE item_id = RDRCD.item_id ORDER BY lu_updated DESC)) --OTHER ANCILLARY
									END
							END
		,main_item_group_code = (SELECT main_item_group_code FROM HISViews.dbo.GEN_vw_parent_item_group WHERE item_id = RDRCD.item_id AND active_flag = 1)
		,main_item_group_name = (SELECT main_item_group_desc FROM HISViews.dbo.GEN_vw_parent_item_group WHERE item_id = RDRCD.item_id AND active_flag = 1)		
		,item_group_code
		,item_group_name
		,item_code
		,item_desc
		,item_type_rcd
		,item_type_name
		,qty
		,total_amount
		,transaction_date_time
		,transaction_type
		,transaction_by
		,service_requestor
		,service_provider
		,gl_acct_code_code
		,gl_acct_name
		,visit_type_rcd
		,visit_type_rcd_after_move
		,bed
	FROM
		HISViews.dbo.RPT_vw_daily_revenue_deletes_detailed RDRCD
	WHERE
		transaction_date_time between @date1 and @date2
	AND
		service_provider IN (SELECT DISTINCT name_l FROM HISReport.dbo.ref_costcentre_daily_revenue_detailed WHERE active_flag = 1)
	AND 
		item_type_rcd IN ('SRV', 'INV')
	

--COMMIT TRAN

--ROLLBACK TRAN










