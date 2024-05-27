CREATE FUNCTION Report_CommonDeclarationsLucia(
	@CurrentCompany AS uniqueidentifier,
	@MessageType AS char(3),
	@TransportMode AS char(3),
	@Origin AS varchar(5),
	@Destination AS varchar(5),
	@Loading AS varchar(5),
	@Arrival AS varchar(5),
	@CreateDateFrom AS smalldatetime,
	@CreateDateTo AS smalldatetime,
	@ImporterPk AS uniqueidentifier,
	@SupplierPk AS uniqueidentifier, 
	@BranchPk AS uniqueidentifier,
	@DepartureDateFrom AS smalldatetime,
	@DepartureDateTo AS smalldatetime,
	@ArrivalDateFrom AS smalldatetime,
	@ArrivalDateTo AS smalldatetime
	)

	returns table 
	 
	as

	return 

		select 
		JE_PK,
		JE_ClusterKey,
 
		JE_AddINfo, 
		JE_DeclarationReference as JobNumber,
		JE_MessageSubType, 
		JE_TransportMode,
		JE_CustomsCommencedDate AS CCCEventTime,
		tevents.CLREventTime,
		ISNULL(ALLARInvoices.BilledAmount, 0) AS BilledAmount,
		ISNULL(ALLARInvoices.InvoicedAmount, 0) AS InvoicedAmount,
		ISNULL(ALLARInvoices.OutstandingAmount, 0) AS OutstandingAmount,
		ISNULL(AllARInvoices.AllARInvoicesOutstandingAmount, 0) AS AllARInvoicesOutstandingAmount,
		ISNULL(AllARInvoices.AllARInvoicesInvoicedAmount, 0) AS AllARInvoicesInvoicedAmount,
        JE_EntryStatus as EntryStatus,
		JE_SystemCreateTimeUtc as CreatedTime, 
		pickupOrDelivery.PickupOrgCode as PickupCode,
		pickupOrDelivery.PickupName as PickupName,
		pickupOrDelivery.DeliveryCode as DeliveryCode,
		pickupOrDelivery.DeliveryName as DeliveryName,
		depot.DepotCode as DepotCode,
		depot.DepotName as DepotName,
		deliveryCartage.OrgCode as DeliveryTransportCode, 
		deliveryCartage.OrgName as DeliveryTransportName, 
		pickupCartage.OrgCode as PickupTransportCode, 
		pickupCartage.OrgName as PickupTransportName, 
		Forwarder.OH_Code as Forwarder, 
		Forwarder.OH_FullName as ForwarderName, 
		Carrier.OH_Code as Carrier , 
		Carrier.OH_FullName as CarrierName , 
		Containers.Value as Containers,
		Containers.Count as ContainerCount,
		JE_MessageType as MessageType,
		JE_ContainerMode as ContainerMode,
		JE_RS_NKServiceLevel as ServiceLevelCode ,
		RS_Description as ServiceLevelName ,
		JE_OH_Supplier,
		JE_OH_Importer,
		Supplier.OH_Code SupplierCode,
		Importer.OH_Code as ImporterCode,
		Supplier.OH_FullName SupplierName,
		Importer.OH_FullName as ImporterName,
		
		EntryNums.EntryNumber as AllEntryNumbers,

		JE_EntryStatus as 		InternalStatusCode,
		JE_masterBill as MasterBill,		
		JE_VesselName ,
		JE_VoyageFlightNo as VoyageFlight,
		JE_RL_NKPortOfLoading as PortOfLoading, 
		JE_ExportDate as DepartureDate,
		JE_RL_NKPortOfArrival as PortofDischarge,
		JE_DateOfArrival as ArrivalDate,
		JE_HouseBill as HouseBill,
		JE_RL_NKOrigin ,
		JE_DateAtOrigin,
		JE_RL_NKFinalDestination ,
		JE_DateAtFinalDestination,
		JE_GoodsDescription as GoodsDescription,
		JE_OwnerRef ,
		JE_TotalNoOfPacks ,
		JE_TotalNoOfPacksPackType,
		JE_TotalWeight as TotalWeight, 
		JE_TotalWeightUnit as TotalWeightUQ, 
		JE_TotalVolume as TotalVolume,
		JE_TotalVolumeUnit as TotalVolumeUQ,
		JE_ShipmentIncoTerm ,
		TransportID  = CONVERT(VARCHAR(27), CASE WHEN CHARINDEX('*Box18TransportID=', '*'+JE_AddInfo) > 0 THEN REPLACE(SUBSTRING('*'+JE_AddInfo, CHARINDEX('*Box18TransportID=', '*'+JE_AddInfo) + 18, CHARINDEX('*', '*'+JE_AddInfo+'*', CHARINDEX('*Box18TransportID=', '*'+JE_AddInfo) + 1) - (CHARINDEX('*Box18TransportID=', '*'+JE_AddInfo) + 18)), '¤', '*') ELSE '' END),
		JE_GB,
		GB_Code as 		BranchCode,
		GlbBranch.GB_BranchName as BranchName,
		UserCreated.GS_Code as CreatingUserCode,
		UserBroker.GS_PK as BrokerUserPK,		
		UserBroker.GS_Code as BrokerUserCode,
		UserCreated.GS_FullName as CreatingUserName,		
		UserBroker.GS_FullName as BrokerUserName,		
		JE_MergeBy as MergeBy,
		JE_IsPersonalEffects,
		JE_ApplicationCode,
		JE_EntrySubmittedDate,
		JE_CustomsOffice,
		JE_GoodsOrigin,
		JE_LocationOfGoods,
		JE_AgentsReference,
		JE_JS,
		JE_OA_DeclarantAddress,
		JE_RN_NKTransportNationality,
		JE_TransportModeInland,
		JE_EntryAuthorisationDate,
		JE_PaymentMethod, 
		JE_DeclarantType, 
		JE_DefermentAccountNumber, 
		JE_IATALoadPort,
		JE_CustomsProfile,
		JE_ComputedParent

from dbo.JobDeclaration 
	--left join dbo.CusEntryHeader  on CH_JE = JobDeclaration.JE_PK  
	
	left join dbo.OrgHeader Supplier  on Supplier.OH_PK = JE_OH_Supplier
	left join dbo.OrgHeader Importer  on Importer.OH_PK = JE_OH_Importer
	inner join dbo.GlbBranch  on JE_GB = GB_PK 
	  
	
	left join dbo.OrgHeader forwarder on JE_OH_Forwarder = forwarder.oh_PK
	left join dbo.OrgHeader carrier  on JE_OH_ShippingLine = carrier.OH_PK
	
	
	-- DEPOT - always on JE, always CDE
	left join 
		(
			select	E2_ParentID, 
					max(OH_Code) as DepotCode,
					max(OH_Fullname) DepotName
					from dbo.OrgHeader  
					inner join dbo.OrgAddress  on OH_PK = OA_OH
					inner join dbo.JobDocAddress  on OA_PK = E2_OA_Address
					where 
					E2_AddressType='CDE'
					group by JobDocAddress.E2_ParentID 
		) as depot on depot.E2_ParentID = JE_pk

		-- Pickup and delivery - on JE or JS, address type varies (pfff)
		left join 
		(
			select	
					JobDocAddress.E2_ParentID,
					max(case when E2_AddressType = 'CRG' or E2_AddressType ='SUG' then OH_Code else null end) as PickupOrgCode, -- Pickup (from) company
					max(case when E2_AddressType = 'CRG' or E2_AddressType ='SUG' then OH_Fullname else null end) as PickupName,-- Pickup (from) company
					max(case when E2_AddressType = 'IMG' or E2_AddressType ='CEG' then OH_Code else null end) as DeliveryCode,
					max(case when E2_AddressType = 'IMG' or E2_AddressType ='CEG' then OH_Fullname else null end) as DeliveryName
					from dbo.OrgHeader
					inner join dbo.OrgAddress  on OH_PK = OA_OH
					inner join dbo.JobDocAddress  on OA_PK = E2_OA_Address
					group by JobDocAddress.E2_ParentID
		) as pickupOrDelivery on pickupOrDelivery.E2_ParentID = JE_ComputedParent
		


		left join 
		( 
		-- Delivery  transport company
			select	JP_ParentID, max(OH_Code) as OrgCode, max(OH_FullName) as OrgName
					from dbo.OrgHeader  
					inner join dbo.OrgAddress  on OH_PK = OA_OH
					inner join dbo.JobDocsAndCartage  on OA_PK = JP_OA_DeliveryCartageCoAddr
					group by JobDocsAndCartage.JP_ParentID
		) as deliveryCartage on deliveryCartage.JP_ParentID = isnull (je_js, JE_PK) 
		
		left join 
		(	-- Pickup  transport company
			select	JP_ParentID, max(OH_Code) as OrgCode, max(OH_FullName) as OrgName
					from dbo.OrgHeader
					inner join dbo.OrgAddress  on OH_PK = OA_OH
					inner join dbo.JobDocsAndCartage  on OA_PK = JP_OA_PickupCartageCoAddr
					group by JobDocsAndCartage.JP_ParentID
		) as  pickupCartage on pickupCartage.JP_ParentID =  isnull (je_js, JE_PK)
	-- end orgs

	left join
	--Event times
	(
		select sl_parent, 
			max(case when SL_SE_NKEvent = 'clr' then SL_EventTime else null end) as CLREventTime
			from dbo.StmALog
			where SL_SE_NKEvent = 'clr' and SL_IsCancelled = 'N' and SL_IsEstimate = 'N'
			group by SL_Parent
	) as tEvents on tEvents.SL_Parent = JE_ComputedParent
	--end event times

	-- AR invoices (nicked from US)	
	LEFT JOIN
	(
		SELECT JH_ParentID,
			SUM(OutstandingAmount) AS OutstandingAmount,
			SUM(InvoicedAmount) AS InvoicedAmount,
			SUM(BilledAmount) AS BilledAmount,
			SUM(AllARInvoicesInvoicedAmount) AS AllARInvoicesInvoicedAmount,
			SUM(AllARInvoicesOutstandingAmount) AS AllARInvoicesOutstandingAmount
		FROM
		(
			SELECT JH_ParentID,
			AH_PK,
			(SUM(CASE WHEN AH_TransactionCategory = 'DBT' OR AL_PK IS NOT NULL THEN AH_OutstandingAmount ELSE 0 END) / COUNT(AH_PK)) AS OutstandingAmount,
			(SUM(CASE WHEN AH_TransactionCategory = 'DBT' OR AL_PK IS NOT NULL THEN AH_InvoiceAmount ELSE 0 END) / COUNT(AH_PK)) AS InvoicedAmount,
			SUM(AL_LineAmount) AS BilledAmount,
			SUM(AH_InvoiceAmount) / COUNT(AH_PK) AS AllARInvoicesInvoicedAmount,
			SUM(AH_OutstandingAmount) / COUNT(AH_PK) AS AllARInvoicesOutstandingAmount
			FROM dbo.JobHeader  
			INNER JOIN dbo.JobDeclaration ON JH_ParentID IN (JE_PK, JE_JS)
			INNER JOIN dbo.AccTransactionHeader  ON AH_JH = JH_PK AND AH_Ledger = 'AR' AND AH_GC = @CurrentCompany 
			LEFT JOIN
			(
				SELECT AL_PK, AL_AH, AL_LineAmount
				FROM dbo.AccTransactionLines  
				INNER JOIN dbo.GlbBranch  ON AL_GB = GB_PK 
				INNER JOIN dbo.GlbCompany gc ON GB_gc = Gc_PK AND GC_PK = @CurrentCompany  
				cross apply dbo.csfn_DisbursementChargeCodes(@CurrentCompany, GC_RN_NKCountryCode) where  ChargeCodePK = AL_AC			
			) AS Lines ON Lines.AL_AH = AH_PK 
			WHERE JH_GC = @CurrentCompany
			GROUP BY JH_ParentID, AH_PK
		) AS ALLARInvoices
		GROUP BY JH_ParentID
	) AS ALLARInvoices ON AllARInvoices.JH_ParentID = JE_ComputedParent


	-- end AR

	 
	inner join dbo.glbCompany on GB_GC = GC_PK
	left outer join dbo.GlbStaff UserCreated on JE_SystemCreateUser = UserCreated.GS_Code
	left outer join dbo.GlbStaff UserBroker  on JE_GS_NKCusAgent = UserBroker.GS_Code
	left outer join dbo.RefServiceLevel on JE_RS_NKServiceLevel = RS_Code 
	cross apply dbo.JobDeclarationContainerInfo(JE_PK, ', ') as containers	
	
	 cross apply dbo.ctfn_GetCustomsEntryNumbers(JE_PK, GC_RN_NKCountryCode) EntryNums
 
	where 
	(@CurrentCompany is null or GB_GC = @CurrentCompany)
	and JE_IsCancelled = 0
	and (@MessageType is null or @MessageType = '' or JE_MessageType = @MessageType)
	and	(@TransportMode is null or @TransportMode = '' or JE_TransportMode = @TransportMode)
	and	(@Origin is null or @Origin = '' or JE_RL_NKOrigin like @Origin+'%')
	and	(@Loading is null or @Loading = '' or JE_RL_NKPortOfLoading like @Loading+'%')	
	and	(@Destination is null or @Destination = '' or JE_RL_NKFinalDestination like @Destination+'%' )
	and	(@Arrival is null or @Arrival = '' or JE_RL_NKPortOfArrival like @Arrival+'%' )
	and (@CreateDateFrom is null or @CreateDateFrom = '' or JE_SystemCreateTimeUtc >= @CreateDateFrom)
	and (@CreateDateTo is null or @CreateDateTo = '' or JE_SystemCreateTimeUtc < dbo.GetNextDateAsSmallDateTime(@CreateDateTo))
	and (@ImporterPk is null or JE_OH_Importer = @ImporterPk)
	and (@SupplierPk is null or JE_OH_Supplier = @SupplierPk)
	and (@branchPk is null or JE_GB = @BranchPk)
	and (@DepartureDateFrom is null or @DepartureDateFrom = '' or JE_ExportDate >= @DepartureDateFrom)
	and (@DepartureDateTo   is null or @DepartureDateTo   = '' or JE_ExportDate < dbo.GetNextDateAsSmallDateTime(@DepartureDateTo))
	and (@ArrivalDateFrom is null or @ArrivalDateFrom = '' or JE_DateOfArrival >= @ArrivalDateFrom)
	and (@ArrivalDateTo   is null or @ArrivalDateTo   = '' or JE_DateOfArrival < dbo.GetNextDateAsSmallDateTime(@ArrivalDateTo))