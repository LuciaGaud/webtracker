create function Report_GBDeclarationsImportLucia(

  -- Filters to pass over to the parent report:
	@CurrentCompany AS uniqueidentifier,
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
	@ArrivalDateTo AS smalldatetime,
	@Route as varchar(3),
	@DeclarationType as varchar(3),
	@Badge as varchar(3),
	@Csp as varchar(5),
	@DeclarantType as varchar(3),
	@ApplicationCode as char(3),
	@MessageType as char(3) = 'IMP',
	@CdsLocationOfGoods as varchar(15),
	-- Filters for this specific report:
	@LocationOfGoods as varchar(5),
	@Shed as varchar(3),
	@IRC as varchar(3),
	@FirstDAN as varchar(7),
	@SecondDAN as varchar(7),
	@FirstDANType as varchar(1),
	@SecondDANType as varchar(1)
)

	returns table --with schemabinding

	as

	return

		select

			-- Fields from Export report
			jobDecExport.JE_PK,
			jobDecExport.JE_AddInfo ,
			jobDecExport.JobNumber,
			jobDecExport.CCCEventTime as ImportCustomsCommencedDate,
			jobDecExport.ClearanceDate,
			jobDecExport.BilledAmount,
			jobDecExport.InvoicedAmount,
			jobDecExport.OutstandingAmount,
			jobDecExport.AllARInvoicesOutstandingAmount,
			jobDecExport.AllARInvoicesInvoicedAmount,

			JobDecExport.JE_GB,
			JobDecExport.JE_OH_Importer,
			JobDecExport.JE_OH_Supplier,
			JobDecExport.EntryStatus,
			jobDecExport.CreatedTime,
			jobDecExport.PickupCode,
			jobDecExport.PickupName,
			jobDecExport.DeliveryCode,
			jobDecExport.DeliveryName,
			jobDecExport.DeliveryTransportCode,
			jobDecExport.DeliveryTransportName,
			jobDecExport.PickupTransportCode,
			jobDecExport.PickupTransportName,
			jobDecExport.DepotCode,
			jobDecExport.DepotName,
			jobDecExport.Forwarder,
			jobDecExport.ForwarderName,
			jobDecExport.Carrier ,
			jobDecExport.CarrierName ,
			jobDecExport.Containers,
			jobDecExport.MessageType,
			jobDecExport.ContainerMode,
			jobDecExport.ServiceLevelCode ,
			jobDecExport.ServiceLevelName ,
			jobDecExport.Box2SupplierCode,
			jobDecExport.Box2SupplierName,
			jobDecExport.Box8ImporterCode,
			jobDecExport.Box8ImporterName,
			jobDecExport.AllEntryNumbers,
			jobDecExport.InternalStatusCode,
			jobDecExport.MasterBill,
			jobDecExport.Box21Vessel,
			jobDecExport.VoyageFlight,
			jobDecExport.PortOfLoading,
			jobDecExport.DepartureDate,
			jobDecExport.PortofDischarge,
			jobDecExport.ArrivalDate,
			jobDecExport.HouseBill,
			jobDecExport.Box15PortOfOrigin,
			jobDecExport.ETD,
			jobDecExport.Box17PortOfDestination,
			jobDecExport.ETA,
			jobDecExport.GoodsDescription,
			jobDecExport.Box7DeclarantsReference,
			jobDecExport.Box6Packages,
			jobDecExport.TotalWeight,
			jobDecExport.TotalWeightUQ,
			jobDecExport.TotalVolume,
			jobDecExport.TotalVolumeUQ,
			jobDecExport.Box20IncoTerm,
			jobDecExport.BranchCode,
			jobDecExport.BranchName,
			jobDecExport.CreatingUserCode,
			jobDecExport.BrokerUserCode,
			jobDecExport.CreatingUserName,
			jobDecExport.BrokerUserName,
			jobDecExport.MergeBy,
			jobDecExport.IsTrainingEntry,
			jobDecExport.Box1DeclarationType,
			jobDecExport.Box1EntryType,
			jobDecExport.Box25TransportMode,
			jobDecExport.CTStatusID,
			jobDecExport.ICS,
			jobDecExport.SOE,
			jobDecExport.RouteOfEntry,
			jobDecExport.IrcInventoryReturnCode,
			jobDecExport.Box26MOT,
			jobDecExport.Box21Nationality,
			jobDecExport.MasterUCR,
			jobDecExport.Badge,
			jobDecExport.CSP,
			jobDecExport.Box49Warehouse,
			jobDecExport.Box44SupervisingOffice,
			jobDecExport.Box30Location,
			jobDecExport.Box30Shed,
			jobDecExport.Box30ShedName,
			--jobDecExport..LCPInspectionDate,
			--jobDecExport.LCPDepartureDate,
			jobDecExport.TaxPoint,
			jobDecExport.RouteFRequested,
			jobDecExport.BasicOrHouse,
			jobDecExport.Box14RepresentationType,
			jobDecExport.Box14Declarant,
			jobDecExport.Box29TransportChargesMOP,
			--jobDecExport.OfficeOfExit
			jobDecExport.Box48OtherDeferralAccount,
			jobDecExport.TransportID,
			jobDecExport.Box61FARP,
		-- End field from export report

			jobDecExport.Box48OtherDeferralType,
			VATDeferType.Value  as Box48VATDeferralType,
			VATDeferNumber.Value  as  Box48VATDeferralAccount,
			ApportionByWeight.Value  as Box64ApportionByWeight,
			OSAirTransportAmount.Value  as Box62AirTransportCosts,
			FrtChgAmt.Value  as Box63FreightCharges,
			RX_NKFrtChg.Value  as Box63FreightChargesCurrency,
			DiscAmt.Value  as Box65DiscountAmount,
			RX_NKDisc.Value  as Box65DiscountCurrency,
			DiscPerc.Value  as Box65DiscountPercent,
			InsAmt.Value  as Box66Insurance,
			RX_NKIns.Value  as Box66InsuranceCurrency,
			OthChgAmt.Value  as Box67OtherCharges,
			RX_NKOthChg.Value   as Box67OtherChargesCurrency,
			VATAdjAmt.Value  as Box68VatAdjustment,
			--jobDecExport.Box29TransportChargesMOP,
			entryCharges.A00 as TotalDutyA00,
			entryCharges.b00 TotalVatB00,
			entryCharges.a30 as TotalDutyA30,
			entryCharges.A35 TotalDutyA35,
			jobDecExport.JE_ApplicationCode

from dbo.Report_GBDeclarationsExportLucia(@CurrentCompany,
	@TransportMode,
	@Origin ,
	@Destination ,
	@Loading ,
	@Arrival ,
	@CreateDateFrom ,
	@CreateDateTo ,
	@ImporterPk ,
	@SupplierPk,
	@BranchPk,
	@DepartureDateFrom,
	@DepartureDateTo,
	@ArrivalDateFrom,
	@ArrivalDateTo,
	@Route,
	@DeclarationType,
	@Badge,
	@Csp,
	@DeclarantType,
	@ApplicationCode,
	@MessageType,
	@CdsLocationOfGoods
)

	as jobDecExport


	left join

	(
		SELECT
			CH_JE,
			SUM(CASE WHEN CF_ChargeType = 'A00' THEN CF_ChargeAmount ELSE 0 END) AS [A00],
			SUM(CASE WHEN CF_ChargeType = 'B00' THEN CF_ChargeAmount ELSE 0 END) AS [B00],
			SUM(CASE WHEN CF_ChargeType = 'A30' THEN CF_ChargeAmount ELSE 0 END) AS [A30],
			SUM(CASE WHEN CF_ChargeType = 'A35' THEN CF_ChargeAmount ELSE 0 END) AS [A35]
		FROM dbo.CusEntryHeader
		LEFT JOIN (
			SELECT
				CH_PK as EntryPK,
				CF_PK as FeePK,
				RANK() OVER (PARTITION BY CH_PK ORDER BY (CASE WHEN CF_Source = 'CUS' THEN 1 ELSE 2 END)) AS CF_SourceFilter
			FROM dbo.CusEntryHeader
			LEFT JOIN dbo.CusEntryLine ON CL_CH = CH_PK
			LEFT JOIN dbo.CusEntryLineFee ON CF_CL = CL_PK AND CF_ChargeType in ('A00', 'B00', 'A30', 'A35') AND CF_IsLandedCostOnly = 0
		) FeesToSum ON FeesToSum.EntryPK = dbo.CusEntryHeader.CH_PK and CF_SourceFilter = 1
		LEFT JOIN dbo.CusEntryLineFee ON CF_PK = FeePK AND CF_IsLandedCostOnly = 0
			GROUP BY
				CH_JE
	) entryCharges
	on entryCharges.CH_JE = jobDecExport.JE_PK
			cross apply dbo.csfn_GetAddInfoValueFromCodeInline(jobDecExport.JE_AddInfo, 'ApportionByWeight') as ApportionByWeight
			cross apply dbo.csfn_GetAddInfoValueFromCodeInline(jobDecExport.JE_AddInfo, 'CTStatusID') as CTStatusID
			cross apply dbo.csfn_GetAddInfoValueFromCodeInline(jobDecExport.JE_AddInfo, 'VATDeferNumber') as VATDeferNumber
			cross apply dbo.csfn_GetAddInfoValueFromCodeInline(jobDecExport.JE_AddInfo, 'VATDeferType') as VATDeferType
			cross apply dbo.csfn_GetAddInfoValueFromCodeInline(jobDecExport.JE_AddInfo, 'DiscAmt') as DiscAmt
			cross apply dbo.csfn_GetAddInfoValueFromCodeInline(jobDecExport.JE_AddInfo, 'DiscPerc') as DiscPerc
			cross apply dbo.csfn_GetAddInfoValueFromCodeInline(jobDecExport.JE_AddInfo, 'FrtChgAmt') as FrtChgAmt
			cross apply dbo.csfn_GetAddInfoValueFromCodeInline(jobDecExport.JE_AddInfo, 'InsAmt') as InsAmt
			cross apply dbo.csfn_GetAddInfoValueFromCodeInline(jobDecExport.JE_AddInfo, 'OSAirTransportAmount') as OSAirTransportAmount
			cross apply dbo.csfn_GetAddInfoValueFromCodeInline(jobDecExport.JE_AddInfo, 'OthChgAmt') as OthChgAmt
			cross apply dbo.csfn_GetAddInfoValueFromCodeInline(jobDecExport.JE_AddInfo, 'RX_NKDisc') as RX_NKDisc
			cross apply dbo.csfn_GetAddInfoValueFromCodeInline(jobDecExport.JE_AddInfo, 'RX_NKFrtChg') as RX_NKFrtChg
			cross apply dbo.csfn_GetAddInfoValueFromCodeInline(jobDecExport.JE_AddInfo, 'RX_NKIns') as RX_NKIns
			cross apply dbo.csfn_GetAddInfoValueFromCodeInline(jobDecExport.JE_AddInfo, 'RX_NKOthChg') as RX_NKOthChg
			cross apply dbo.csfn_GetAddInfoValueFromCodeInline(jobDecExport.JE_AddInfo, 'RX_NKVATAdj') as RX_NKVATAdj
			cross apply dbo.csfn_GetAddInfoValueFromCodeInline(jobDecExport.JE_AddInfo, 'VATAdjAmt') as VATAdjAmt

	  where
			(@LocationOfGoods is null or @LocationOfGoods = '' or @LocationOfGoods=jobDecExport.Box30Location)
		and (@Shed is null or @Shed = '' or @Shed=jobDecExport.Box30Shed)
		and (@FirstDAN is null or @FirstDAN = '' or @FirstDAN=jobDecExport.Box48OtherDeferralAccount)
		and (@SecondDAN is null or @SecondDAN = '' or @SecondDAN=VATDeferNumber.Value)
		and (@FirstDANType is null or @FirstDANType = '' or @FirstDANType= jobDecExport.Box48OtherDeferralType)
		and (@SecondDANType is null or @SecondDANType = '' or @SecondDANType=VATDeferType.Value)
		and (@IRC is null or @IRC = '' or @IRC = jobDecExport.IrcInventoryReturnCode)