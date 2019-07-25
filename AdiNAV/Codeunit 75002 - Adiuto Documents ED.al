codeunit 75002 "Adiuto Documents ED"
{
    // version ADI.003

    // ADI-001
    //   dynamic field check
    // 
    // ADI-002
    //   style for status columns
    // 
    // JM-FM20190416
    //   bug-fix for adiuto commit

    Permissions = TableData 5992 = rm,
                  TableData 5994 = rm;

    trigger OnRun()
    var
        lRecAdiutoSetup: Record "Adiuto Setup ED";
        lCduAdiutoEIManagement: Codeunit "Adiuto ED Management";
    begin
        lRecAdiutoSetup.GET;
        AdiutoElectrInvoiceDownloadAll(FALSE);
        IF lRecAdiutoSetup."Electr. Doc. Pre-Reg. Enable" THEN
            lCduAdiutoEIManagement.AdiutoElectrInvoiceImportProcess(FALSE)
        ELSE
            AdiutoElectrInvoiceSaveFileXML();
    end;

    var
        gCduAdiutoNetWebService: Codeunit "Adiuto Net Web Service ED";

    procedure ViewDocumentByBarcode(pTxtBarcode: Text)
    begin
        RunSDKByBarcode(pTxtBarcode);
    end;

    local procedure RunSDKByBarcode(pTxtBarcode: Text)
    var
        lRecAdiutoSetup: Record "Adiuto Setup ED";
        lRecAdiutoSetupDetail: Record "Adiuto Setup Detail ED";
        lRecAdiutoElectrInv: Record "Adiuto Electr. Doc.";
        lTxtParam: Text;
        //TODO        wSHShell: Automation ;
        lIntDummy: Integer;
        lBlnShowModal: Boolean;
        lRecUser: Record User;
        lText001: Label 'SDK Web coming soon';
        lFldRef: FieldRef;
        lTxtUrlPath: BigText;
    begin
        lRecAdiutoSetup.GET;
        //se non abilitato non eseguo le funzioni di adiuto
        IF NOT lRecAdiutoSetup.Enable THEN
            EXIT;
        lRecAdiutoSetup.TESTFIELD("SDK Type");

        lRecAdiutoElectrInv.RESET;
        lRecAdiutoElectrInv.SETRANGE(Barcode, pTxtBarcode);
        IF NOT lRecAdiutoElectrInv.FINDFIRST THEN
            EXIT;

        lRecAdiutoSetupDetail.RESET;
        lRecAdiutoSetupDetail.SETRANGE("XML Document", lRecAdiutoSetupDetail."XML Document"::"Passive XML");
        lRecAdiutoSetupDetail.SETRANGE("Table Id", lRecAdiutoElectrInv."Table Id");
        IF NOT lRecAdiutoSetupDetail.FINDFIRST THEN
            EXIT;

        IF lRecAdiutoSetup."SDK Type" = lRecAdiutoSetup."SDK Type"::Standard THEN BEGIN
            lTxtParam := '';
            //lTxtParam := ' U:' + pRecAdiutoSetup.User + '|P:' + pRecAdiutoSetup.Password + '|' + pRec."Name Family Document" + '|' + pRec."Name Get Field" + '|' + pCodDocNo;
            IF lRecAdiutoSetup."Enable Connected Users" THEN BEGIN
                IF lRecUser.GET(USERSECURITYID) THEN BEGIN
                    //>ADI-001
                    //lRecUser.TESTFIELD("Adiuto Connected User");
                    //lTxtParam := ' UC:' + lRecUser."Adiuto Connected User" + '|';

                    lTxtParam := ' UC:' + GetConnectedUser(lRecUser) + '|';
                    //<ADI-001
                END;
            END;

            lTxtParam := lTxtParam + lRecAdiutoSetupDetail."Name Family Document";

            IF (lRecAdiutoElectrInv.Barcode <> '') THEN
                lTxtParam := lTxtParam + '|' + lRecAdiutoSetupDetail."El. Doc. Barcode Fld. Name" + '|' + lRecAdiutoElectrInv.Barcode;

            IF (lRecAdiutoSetup."Field Company Name" <> '') AND (lRecAdiutoSetup."Value Field Company" <> '') THEN
                lTxtParam := lTxtParam + '|' + lRecAdiutoSetup."Field Company Name" + '|' + lRecAdiutoSetup."Value Field Company";

            //TODO          CREATE(wSHShell,FALSE,TRUE);
            //TODO          wSHShell.Run('"' + lRecAdiutoSetup."Path SDK" + '"' + lTxtParam,lIntDummy,lBlnShowModal);
            //TODO          CLEAR(wSHShell);
        END
        ELSE BEGIN
            //  ERROR(lText001);
            gCduAdiutoNetWebService.ExecuteQueryRestByBarcode(lRecAdiutoSetupDetail, lRecAdiutoElectrInv.Barcode, lTxtUrlPath);
            HYPERLINK(FORMAT(lTxtUrlPath));
        END;
    end;

    procedure ViewDocuments(pOptDocumentType: Option; pRecRef: RecordRef)
    var
        lRecAdiutoSetup: Record "Adiuto Setup ED";
        lCduAdiutoDocuments: Codeunit "Adiuto Documents ED";
        lRecAdiutoSetupDetail: Record "Adiuto Setup Detail ED";
        lPagAdiutoFamilyList: Page "Adiuto Family List ED";
        lFldRef: FieldRef;
        lRidRecordID: RecordID;
        lCtx001: Label 'No document families have been configured for the current document';
    begin
        lRecAdiutoSetup.GET;
        IF NOT lRecAdiutoSetup.Enable THEN
            EXIT;

        lRidRecordID := pRecRef.RECORDID;
        lRecAdiutoSetupDetail.SETCURRENTKEY(Description);
        lRecAdiutoSetupDetail.SETRANGE("Table Id", lRidRecordID.TABLENO);
        lRecAdiutoSetupDetail.SETRANGE("Document Type", pOptDocumentType);
        lRecAdiutoSetupDetail.SETFILTER("XML Document", '%1|%2', lRecAdiutoSetupDetail."XML Document"::" ", lRecAdiutoSetupDetail."XML Document"::"Variation Note");
        IF lRecAdiutoSetupDetail.FINDSET THEN BEGIN
            IF lRecAdiutoSetupDetail.COUNT > 1 THEN BEGIN
                lPagAdiutoFamilyList.LOOKUPMODE(TRUE);
                lPagAdiutoFamilyList.SetAdiutoNav(1);
                lPagAdiutoFamilyList.GetNavFamilies(lRecAdiutoSetupDetail);
                IF lPagAdiutoFamilyList.RUNMODAL = ACTION::LookupOK THEN BEGIN
                    lPagAdiutoFamilyList.GetNavSelectedRecord(lRecAdiutoSetupDetail);
                    RunSDK(lRecAdiutoSetupDetail, pRecRef);
                END;
            END
            ELSE BEGIN
                RunSDK(lRecAdiutoSetupDetail, pRecRef);
            END;
        END
        ELSE
            MESSAGE(lCtx001);
    end;

    procedure ViewDocumentsFromVariantRec(pOptDocumentType: Option; pRecordVariant: Variant)
    var
        lCtx001: Label 'No document families have been configured for the current document';
        lRefRecord: RecordRef;
    begin
        lRefRecord.GETTABLE(pRecordVariant);
        ViewDocuments(pOptDocumentType, lRefRecord);
    end;

    local procedure RunSDK(pRecAdiutoSetupDetail: Record "Adiuto Setup Detail ED"; pRecRef: RecordRef)
    var
        lRecAdiutoSetup: Record "Adiuto Setup ED";
        lRecAdiutoSetupDetailLines: Record "Adiuto Setup Detail Lines ED";
        lTxtParam: Text;
        //TODO        wSHShell: Automation ;
        lIntDummy: Integer;
        lBlnShowModal: Boolean;
        lRecUser: Record User;
        lText001: Label 'SDK Web coming soon';
        lFldRef: FieldRef;
        lTxtUrlPath: BigText;
        lCduAdiutoNetWebServiceED: Codeunit "Adiuto Net Web Service ED";
    begin
        lRecAdiutoSetup.GET;
        //se non abilitato non eseguo le funzioni di adiuto
        IF NOT lRecAdiutoSetup.Enable THEN
            EXIT;
        lRecAdiutoSetup.TESTFIELD("SDK Type");

        IF lRecAdiutoSetup."SDK Type" = lRecAdiutoSetup."SDK Type"::Standard THEN BEGIN
            lTxtParam := '';
            //lTxtParam := ' U:' + pRecAdiutoSetup.User + '|P:' + pRecAdiutoSetup.Password + '|' + pRec."Name Family Document" + '|' + pRec."Name Get Field" + '|' + pCodDocNo;
            IF lRecAdiutoSetup."Enable Connected Users" THEN BEGIN
                IF lRecUser.GET(USERSECURITYID) THEN BEGIN
                    //>ADI-001
                    //lRecUser.TESTFIELD("Adiuto Connected User");
                    //lTxtParam := ' UC:' + lRecUser."Adiuto Connected User" + '|';

                    lTxtParam := ' UC:' + GetConnectedUser(lRecUser) + '|';
                    //<ADI-001
                END;
            END;

            lTxtParam := lTxtParam + pRecAdiutoSetupDetail."Name Family Document";

            lRecAdiutoSetupDetailLines.RESET;
            lRecAdiutoSetupDetailLines.SETRANGE("Primary Key", pRecAdiutoSetupDetail."Primary Key");
            lRecAdiutoSetupDetailLines.SETRANGE("Line No.", pRecAdiutoSetupDetail."Line No.");
            lRecAdiutoSetupDetailLines.SETRANGE("Use for Searching", TRUE);
            IF lRecAdiutoSetupDetailLines.FINDSET THEN BEGIN
                REPEAT
                    lFldRef := pRecRef.FIELD(lRecAdiutoSetupDetailLines."NAV Field Id");
                    lTxtParam := lTxtParam + '|' + lRecAdiutoSetupDetailLines."Adiuto Field Name" + '|' + lCduAdiutoNetWebServiceED.GetFieldValue(pRecRef, lRecAdiutoSetupDetailLines);
                UNTIL lRecAdiutoSetupDetailLines.NEXT = 0;
            END;

            IF (lRecAdiutoSetup."Field Company Name" <> '') AND (lRecAdiutoSetup."Value Field Company" <> '') THEN
                lTxtParam := lTxtParam + '|' + lRecAdiutoSetup."Field Company Name" + '|' + lRecAdiutoSetup."Value Field Company";

            //TODO          CREATE(wSHShell,FALSE,TRUE);
            //TODO          wSHShell.Run('"' + lRecAdiutoSetup."Path SDK" + '"' + lTxtParam,lIntDummy,lBlnShowModal);
            //TODO          CLEAR(wSHShell);
        END
        ELSE BEGIN
            //  ERROR(lText001);
            gCduAdiutoNetWebService.ExecuteQueryRest(pRecAdiutoSetupDetail, pRecRef, lTxtUrlPath);
            HYPERLINK(FORMAT(lTxtUrlPath));
        END;
    end;

    procedure InsertDoc(pTxtFileName: Text; pIntNoVersion: Integer; pReportId: Integer; var pRefRecord: RecordRef)
    var
        lRecAdiutoSetup: Record "Adiuto Setup ED";
        lRecAdiutoSetupDetail: Record "Adiuto Setup Detail ED";
        lReiRecordID: RecordID;
        lIntPos: Integer;
        PathHelper: DotNet Path;
        lVarRecord: Variant;
        lTxtFileName: Text[250];
        lTxtIdSocieta: Text[20];
        lTxtNoVersion: Text;
        Convert: DotNet Convert;
        ClientFile: DotNet File;
        lCduFileManagement: Codeunit "File Management";
        lTxtFilePath: Text;
        lTxtFileContent: Text;
    begin
        lRecAdiutoSetup.GET;
        //se non abilitato non eseguo le funzioni di adiuto
        IF NOT lRecAdiutoSetup.Enable THEN
            EXIT;

        lRecAdiutoSetupDetail.RESET;
        lRecAdiutoSetupDetail.SETRANGE("Primary Key", lRecAdiutoSetup."Primary Key");
        lRecAdiutoSetupDetail.SETRANGE("Table Id", pRefRecord.NUMBER);
        lRecAdiutoSetupDetail.SETRANGE("Report Id", pReportId);
        lRecAdiutoSetupDetail.SETRANGE("Create Document", TRUE);
        lRecAdiutoSetupDetail.SETRANGE(Canceled, FALSE);
        IF NOT lRecAdiutoSetupDetail.FINDFIRST THEN
            EXIT;

        lTxtFilePath := GetFilePath(pTxtFileName, lRecAdiutoSetupDetail);
        lVarRecord := pRefRecord;
        IF lRecAdiutoSetupDetail."El. Doc. Att. Rpt. Setup Code" = '' THEN
            REPORT.SAVEASPDF(lRecAdiutoSetupDetail."Report Id", lTxtFilePath, lVarRecord)
        ELSE BEGIN
            OnBeforeReportPrint(lVarRecord, lRecAdiutoSetupDetail."Report Id", lRecAdiutoSetupDetail."El. Doc. Att. Rpt. Setup Code");
            REPORT.SAVEASPDF(lRecAdiutoSetupDetail."Report Id", lTxtFilePath);
        END;

        lTxtFileContent := Convert.ToBase64String(ClientFile.ReadAllBytes(lTxtFilePath));
        lTxtFileName := lCduFileManagement.GetFileName(lTxtFilePath);

        gCduAdiutoNetWebService.InsertDocument(lTxtFileName, lTxtFileContent, lRecAdiutoSetupDetail, pRefRecord);
    end;

    procedure InsertDocWithCode(pTxtFileName: Text; pIntNoVersion: Integer; pReportId: Integer; var pRefRecord: RecordRef; ReportCode: Code[10])
    var
        lRecAdiutoSetup: Record "Adiuto Setup ED";
        lRecAdiutoSetupDetail: Record "Adiuto Setup Detail ED";
        lReiRecordID: RecordID;
        lIntPos: Integer;
        PathHelper: DotNet Path;
        lVarRecord: Variant;
        lTxtFileName: Text[250];
        lTxtIdSocieta: Text[20];
        lTxtNoVersion: Text;
        Convert: DotNet Convert;
        ClientFile: DotNet File;
        lCduFileManagement: Codeunit "File Management";
        lTxtFilePath: Text;
        lTxtFileContent: Text;
    begin
        lRecAdiutoSetup.GET;
        //se non abilitato non eseguo le funzioni di adiuto
        IF NOT lRecAdiutoSetup.Enable THEN
            EXIT;

        lRecAdiutoSetupDetail.RESET;
        lRecAdiutoSetupDetail.SETRANGE("Primary Key", lRecAdiutoSetup."Primary Key");
        lRecAdiutoSetupDetail.SETRANGE("Table Id", pRefRecord.NUMBER);
        lRecAdiutoSetupDetail.SETRANGE("Report Id", pReportId);
        lRecAdiutoSetupDetail.SETRANGE("Create Document", TRUE);
        IF ReportCode <> '' THEN
            lRecAdiutoSetupDetail.SETRANGE("El. Doc. Att. Rpt. Setup Code", ReportCode);
        lRecAdiutoSetupDetail.SETRANGE(Canceled, FALSE);
        IF NOT lRecAdiutoSetupDetail.FINDFIRST THEN
            EXIT;

        lTxtFilePath := GetFilePath(pTxtFileName, lRecAdiutoSetupDetail);
        lVarRecord := pRefRecord;
        IF lRecAdiutoSetupDetail."El. Doc. Att. Rpt. Setup Code" = '' THEN
            REPORT.SAVEASPDF(lRecAdiutoSetupDetail."Report Id", lTxtFilePath, lVarRecord)
        ELSE BEGIN
            OnBeforeReportPrint(lVarRecord, lRecAdiutoSetupDetail."Report Id", lRecAdiutoSetupDetail."El. Doc. Att. Rpt. Setup Code");
            REPORT.SAVEASPDF(lRecAdiutoSetupDetail."Report Id", lTxtFilePath);
        END;

        lTxtFileContent := Convert.ToBase64String(ClientFile.ReadAllBytes(lTxtFilePath));
        lTxtFileName := lCduFileManagement.GetFileName(lTxtFilePath);

        gCduAdiutoNetWebService.InsertDocument(lTxtFileName, lTxtFileContent, lRecAdiutoSetupDetail, pRefRecord);
    end;

    procedure InsertDocFromVariantRec(pIntReportId: Integer; RecordVariant: Variant)
    var
        lRecAdiutoSetup: Record "Adiuto Setup ED";
        lRecAdiutoSetupDetail: Record "Adiuto Setup Detail ED";
        lRecAdiutoSetupDetailLines: Record "Adiuto Setup Detail Lines ED";
        lRefRecord: RecordRef;
        lFieldRef: FieldRef;
        lText: Text;
    begin
        lRecAdiutoSetup.GET;
        IF NOT lRecAdiutoSetup.Enable THEN
            EXIT;

        lRefRecord.GETTABLE(RecordVariant);

        lRecAdiutoSetupDetail.RESET;
        lRecAdiutoSetupDetail.SETRANGE("Primary Key", lRecAdiutoSetup."Primary Key");
        lRecAdiutoSetupDetail.SETRANGE("Table Id", lRefRecord.NUMBER);
        lRecAdiutoSetupDetail.SETRANGE("Report Id", pIntReportId);
        lRecAdiutoSetupDetail.SETRANGE("Create Document", TRUE);
        lRecAdiutoSetupDetail.SETRANGE(Canceled, FALSE);
        IF lRecAdiutoSetupDetail.FINDFIRST THEN BEGIN
            lText := GetFileName(lRecAdiutoSetupDetail, lRefRecord);

            InsertDoc(lText, 0, pIntReportId, lRefRecord);
        END;
    end;

    procedure InsertDocFromVariantRecWithRptCode(pIntReportId: Integer; RecordVariant: Variant; ReportCode: Code[10])
    var
        lRecAdiutoSetup: Record "Adiuto Setup ED";
        lRecAdiutoSetupDetail: Record "Adiuto Setup Detail ED";
        lRecAdiutoSetupDetailLines: Record "Adiuto Setup Detail Lines ED";
        lRefRecord: RecordRef;
        lFieldRef: FieldRef;
        lText: Text;
    begin
        lRecAdiutoSetup.GET;
        IF NOT lRecAdiutoSetup.Enable THEN
            EXIT;

        lRefRecord.GETTABLE(RecordVariant);

        lRecAdiutoSetupDetail.RESET;
        lRecAdiutoSetupDetail.SETRANGE("Primary Key", lRecAdiutoSetup."Primary Key");
        lRecAdiutoSetupDetail.SETRANGE("Table Id", lRefRecord.NUMBER);
        lRecAdiutoSetupDetail.SETRANGE("Report Id", pIntReportId);
        lRecAdiutoSetupDetail.SETRANGE("Create Document", TRUE);
        IF ReportCode <> '' THEN
            lRecAdiutoSetupDetail.SETRANGE("El. Doc. Att. Rpt. Setup Code", ReportCode);
        lRecAdiutoSetupDetail.SETRANGE(Canceled, FALSE);
        IF lRecAdiutoSetupDetail.FINDFIRST THEN BEGIN
            lText := GetFileName(lRecAdiutoSetupDetail, lRefRecord);

            InsertDocWithCode(lText, 0, pIntReportId, lRefRecord, ReportCode);
        END;
    end;

    procedure InsertDocPhantom(var pRefRecord: RecordRef; pIntDocumentType: Integer)
    var
        lRecAdiutoSetup: Record "Adiuto Setup ED";
        lRecAdiutoSetupDetail: Record "Adiuto Setup Detail ED";
        lReiRecordID: RecordID;
        lIntPos: Integer;
        lTxtFileName: Text;
        lTxtFileContent: Text;
    begin
        lRecAdiutoSetup.GET;
        //se non abilitato non eseguo le funzioni di adiuto
        IF NOT lRecAdiutoSetup.Enable THEN
            EXIT;

        lRecAdiutoSetupDetail.RESET;
        lRecAdiutoSetupDetail.SETRANGE("Primary Key", lRecAdiutoSetup."Primary Key");
        lRecAdiutoSetupDetail.SETRANGE("Table Id", pRefRecord.NUMBER);
        lRecAdiutoSetupDetail.SETRANGE("Document Type", pIntDocumentType);
        lRecAdiutoSetupDetail.SETRANGE(Phantom, TRUE);
        lRecAdiutoSetupDetail.SETRANGE("Create Document", TRUE);
        lRecAdiutoSetupDetail.SETRANGE(Canceled, FALSE);
        IF NOT lRecAdiutoSetupDetail.FINDFIRST THEN
            EXIT;

        lTxtFileName := GetFileName(lRecAdiutoSetupDetail, pRefRecord);
        lTxtFileContent := '';

        gCduAdiutoNetWebService.InsertDocument(lTxtFileName, lTxtFileContent, lRecAdiutoSetupDetail, pRefRecord);
    end;

    procedure InsertDocPhantomFromVariantRec(RecordVariant: Variant; pIntDocumentType: Integer)
    var
        lRecAdiutoSetup: Record "Adiuto Setup ED";
        lRecAdiutoSetupDetail: Record "Adiuto Setup Detail ED";
        lRecAdiutoSetupDetailLines: Record "Adiuto Setup Detail Lines ED";
        lRefRecord: RecordRef;
        lFieldRef: FieldRef;
        lText: Text;
    begin
        lRefRecord.GETTABLE(RecordVariant);
        InsertDocPhantom(lRefRecord, pIntDocumentType);
    end;

    procedure InsertDocFromVariantRecDocumentType(pIntDocumentId: Integer; RecordVariant: Variant)
    var
        lRecAdiutoSetup: Record "Adiuto Setup ED";
        lRecAdiutoSetupDetail: Record "Adiuto Setup Detail ED";
        lRecAdiutoSetupDetailLines: Record "Adiuto Setup Detail Lines ED";
        lRefRecord: RecordRef;
        lFieldRef: FieldRef;
        lText: Text;
    begin
        lRecAdiutoSetup.GET;
        IF NOT lRecAdiutoSetup.Enable THEN
            EXIT;

        lRefRecord.GETTABLE(RecordVariant);

        lRecAdiutoSetupDetail.RESET;
        lRecAdiutoSetupDetail.SETRANGE("Primary Key", lRecAdiutoSetup."Primary Key");
        lRecAdiutoSetupDetail.SETRANGE("Table Id", lRefRecord.NUMBER);
        lRecAdiutoSetupDetail.SETRANGE("Document Type", pIntDocumentId);
        lRecAdiutoSetupDetail.SETRANGE("Create Document", TRUE);
        lRecAdiutoSetupDetail.SETRANGE("XML Document", lRecAdiutoSetupDetail."XML Document"::" ");
        lRecAdiutoSetupDetail.SETRANGE(Canceled, FALSE);
        IF lRecAdiutoSetupDetail.FINDFIRST THEN BEGIN
            lText := GetFileName(lRecAdiutoSetupDetail, lRefRecord);

            InsertDoc(lText, 0, lRecAdiutoSetupDetail."Report Id", lRefRecord);
        END;
    end;

    procedure ModifyDoc(var pRefRecord: RecordRef)
    var
        lRecAdiutoSetup: Record "Adiuto Setup ED";
        lRecAdiutoSetupDetail: Record "Adiuto Setup Detail ED";
        lReiRecordID: RecordID;
        lIntPos: Integer;
        lTxtResult: Text[250];
        lIntDocumentId: Integer;
    begin
        lRecAdiutoSetup.GET;
        //se non abilitato non eseguo le funzioni di adiuto
        IF NOT lRecAdiutoSetup.Enable THEN
            EXIT;

        lRecAdiutoSetupDetail.RESET;
        lRecAdiutoSetupDetail.SETRANGE("Primary Key", lRecAdiutoSetup."Primary Key");
        lRecAdiutoSetupDetail.SETRANGE("Table Id", pRefRecord.NUMBER);
        //lRecAdiutoSetupDetail.SETRANGE("Create Document",TRUE);
        lRecAdiutoSetupDetail.SETRANGE(Canceled, FALSE);
        IF NOT lRecAdiutoSetupDetail.FINDFIRST THEN
            EXIT;

        lIntDocumentId := 0;
        lTxtResult := gCduAdiutoNetWebService.GetDocId(lRecAdiutoSetupDetail, pRefRecord);
        EVALUATE(lIntDocumentId, lTxtResult);

        IF lIntDocumentId > 0 THEN BEGIN
            gCduAdiutoNetWebService.ModifyDocument(lIntDocumentId, lRecAdiutoSetupDetail, pRefRecord);
        END;
    end;

    procedure ModifyDocFromVariantRec(RecordVariant: Variant)
    var
        lRecAdiutoSetup: Record "Adiuto Setup ED";
        lRefRecord: RecordRef;
    begin
        lRecAdiutoSetup.GET;
        IF NOT lRecAdiutoSetup.Enable THEN
            EXIT;

        lRefRecord.GETTABLE(RecordVariant);
        ModifyDoc(lRefRecord);
    end;

    procedure GetDocument(pIntTableId: Integer; pOptDocType: Option; pRefRecord: RecordRef): Text
    var
        lRecAdiutoSetup: Record "Adiuto Setup ED";
        lRecAdiutoSetupDetail: Record "Adiuto Setup Detail ED";
        lTxtServerFile: Text;
        lTxtClientFile: Text;
        lCduFileManagement: Codeunit "File Management";
    begin
        IF lRecAdiutoSetup.GET THEN BEGIN
            //se non abilitato non eseguo le funzioni di adiuto
            IF NOT lRecAdiutoSetup.Enable THEN
                EXIT;

            lRecAdiutoSetupDetail.SETRANGE("Primary Key", lRecAdiutoSetup."Primary Key");
            lRecAdiutoSetupDetail.SETRANGE("Table Id", pIntTableId);
            lRecAdiutoSetupDetail.SETRANGE("Document Type", pOptDocType);
            lRecAdiutoSetupDetail.SETRANGE("Create Document", TRUE);
            IF lRecAdiutoSetupDetail.FIND('-') THEN BEGIN
                lTxtServerFile := gCduAdiutoNetWebService.GetDocument(lRecAdiutoSetupDetail, pRefRecord, lRecAdiutoSetupDetail."File Extension");
                EXIT(lTxtServerFile);
            END;
        END;
    end;

    procedure OpenDocument(pIntTableId: Integer; pOptDocType: Option; pRefRecord: RecordRef): Text
    var
        lRecAdiutoSetup: Record "Adiuto Setup ED";
        lRecAdiutoSetupDetail: Record "Adiuto Setup Detail ED";
        lTxtServerFile: Text;
        lTxtClientFile: Text;
        lCduFileManagement: Codeunit "File Management";
    begin
        lTxtServerFile := GetDocument(pIntTableId, pOptDocType, pRefRecord);
        IF NOT lCduFileManagement.ServerFileExists(lTxtServerFile) THEN
            ERROR(lTxtServerFile);
        lTxtClientFile := lCduFileManagement.DownloadTempFile(lTxtServerFile);
        HYPERLINK(lTxtClientFile);
    end;

    procedure OpenDocumentFromVariantRec(RecordVariant: Variant; pIntDocumentType: Integer)
    var
        lRecAdiutoSetup: Record "Adiuto Setup ED";
        lRefRecord: RecordRef;
    begin
        lRecAdiutoSetup.GET;
        IF NOT lRecAdiutoSetup.Enable THEN
            EXIT;

        lRefRecord.GETTABLE(RecordVariant);
        GetDocument(lRefRecord.NUMBER, pIntDocumentType, lRefRecord);
    end;

    procedure CheckPurchaseInvoice(pRecPurchaseHeader: Record "Purchase Header")
    var
        lRecAdiutoSetup: Record "Adiuto Setup ED";
        lCtx001: Label 'Barcode obbligatorio';
        lRecPurchInvHeader: Record "Purch. Inv. Header";
        lCtx002: Label 'Barcode già presente sulla fattura nr. %1, vuoi continuare?';
        lRecordRef: RecordRef;
        lFieldRef: FieldRef;
        lFieldRefFilter: FieldRef;
        lRecordRefFilter: RecordRef;
    begin
        lRecAdiutoSetup.GET;
        IF NOT lRecAdiutoSetup.Enable THEN
            EXIT;

        IF lRecAdiutoSetup."Mandatory Invoice Barcode" THEN BEGIN
            //>ADI-001
            //pRecPurchaseHeader.TESTFIELD("Barcode Invoice Document");

            lRecAdiutoSetup.TESTFIELD("Invoice Barcode Field No.");
            lRecordRef.GETTABLE(pRecPurchaseHeader);
            lFieldRef := lRecordRef.FIELD(lRecAdiutoSetup."Invoice Barcode Field No.");
            lFieldRef.TESTFIELD;
            //<ADI-001
        END;

        IF lRecAdiutoSetup."Check Invoice Barcode Dup." THEN BEGIN
            //>ADI-001
            //lRecPurchInvHeader.SETRANGE("Barcode Invoice Document",pRecPurchaseHeader."Barcode Invoice Document");
            //IF lRecPurchInvHeader.FIND('-') THEN BEGIN

            lRecAdiutoSetup.TESTFIELD("Invoice Barcode Field No.");
            lRecordRef.GETTABLE(pRecPurchaseHeader);
            lFieldRef := lRecordRef.FIELD(lRecAdiutoSetup."Invoice Barcode Field No.");

            lRecPurchInvHeader.RESET;
            lRecordRefFilter.GETTABLE(lRecPurchInvHeader);
            lFieldRefFilter := lRecordRefFilter.FIELD(lRecAdiutoSetup."Invoice Barcode Field No.");
            lFieldRefFilter.SETRANGE(FORMAT(lFieldRef.VALUE));
            IF NOT lRecordRefFilter.ISEMPTY THEN BEGIN
                lRecordRefFilter.SETTABLE(lRecPurchInvHeader);
                //<ADI-001
                IF NOT CONFIRM(lCtx002, TRUE, lRecPurchInvHeader."No.") THEN
                    ERROR('');
            END;
        END;
    end;

    procedure CheckPurchaseReceipt(pRecPurchaseHeader: Record "Purchase Header")
    var
        lRecAdiutoSetup: Record "Adiuto Setup ED";
        lRecPurchasesPayablesSetup: Record "Purchases & Payables Setup";
        lCtx001: Label 'Barcode obbligatorio';
        lRecPurchRcptHeader: Record "Purch. Rcpt. Header";
        lCtx002: Label 'Barcode già presente sulla ricezione merce nr. %1, vuoi continuare?';
        lRecPurchInvHeader: Record "Purch. Inv. Header";
        lCtx003: Label 'Barcode già presente sulla fattura nr. %1, vuoi continuare?';
        lRecordRef: RecordRef;
        lFieldRef: FieldRef;
        lFieldRefFilter: FieldRef;
        lRecordRefFilter: RecordRef;
    begin
        lRecAdiutoSetup.GET;
        IF NOT lRecAdiutoSetup.Enable THEN
            EXIT;

        IF pRecPurchaseHeader.Receive THEN BEGIN
            IF lRecAdiutoSetup."Mandatory Receipt Barcode" THEN BEGIN
                //>ADI-001
                //pRecPurchaseHeader.TESTFIELD("Barcode Delivery Document");

                lRecAdiutoSetup.TESTFIELD("Delivery Barcode Field No.");
                lRecordRef.GETTABLE(pRecPurchaseHeader);
                lFieldRef := lRecordRef.FIELD(lRecAdiutoSetup."Delivery Barcode Field No.");
                lFieldRef.TESTFIELD;
                //<ADI-001
            END;

            IF lRecAdiutoSetup."Check Rcpt. Barcode Duplicate" THEN BEGIN
                //>ADI-001
                //lRecPurchRcptHeader.SETRANGE("Barcode Delivery Document",pRecPurchaseHeader."Barcode Delivery Document");
                //IF lRecPurchRcptHeader.FIND('-') THEN BEGIN

                lRecAdiutoSetup.TESTFIELD("Delivery Barcode Field No.");
                lRecordRef.GETTABLE(pRecPurchaseHeader);
                lFieldRef := lRecordRef.FIELD(lRecAdiutoSetup."Delivery Barcode Field No.");

                lRecPurchRcptHeader.RESET;
                lRecordRefFilter.GETTABLE(lRecPurchRcptHeader);
                lFieldRefFilter := lRecordRefFilter.FIELD(lRecAdiutoSetup."Delivery Barcode Field No.");
                lFieldRefFilter.SETRANGE(FORMAT(lFieldRef.VALUE));
                IF NOT lRecordRefFilter.ISEMPTY THEN BEGIN
                    lRecordRefFilter.SETTABLE(lRecPurchRcptHeader);
                    //<ADI-001
                    IF NOT CONFIRM(lCtx002, TRUE, lRecPurchRcptHeader."No.") THEN
                        ERROR('');
                END;
            END;
        END;

        IF pRecPurchaseHeader.Invoice THEN BEGIN
            IF lRecAdiutoSetup."Mandatory Invoice Barcode" THEN BEGIN
                //>ADI-001
                //pRecPurchaseHeader.TESTFIELD("Barcode Invoice Document");

                lRecAdiutoSetup.TESTFIELD("Invoice Barcode Field No.");
                lRecordRef.GETTABLE(pRecPurchaseHeader);
                lFieldRef := lRecordRef.FIELD(lRecAdiutoSetup."Invoice Barcode Field No.");
                lFieldRef.TESTFIELD;
                //<ADI-001
            END;

            IF lRecAdiutoSetup."Check Invoice Barcode Dup." THEN BEGIN
                //>ADI-001
                //lRecPurchInvHeader.SETRANGE("Barcode Invoice Document",pRecPurchaseHeader."Barcode Invoice Document");
                //IF lRecPurchInvHeader.FIND('-') THEN
                IF NOT CONFIRM(lCtx003, TRUE, lRecPurchInvHeader."No.") THEN
                    ERROR('');

                lRecAdiutoSetup.TESTFIELD("Invoice Barcode Field No.");
                lRecordRef.GETTABLE(pRecPurchaseHeader);
                lFieldRef := lRecordRef.FIELD(lRecAdiutoSetup."Invoice Barcode Field No.");

                lRecPurchInvHeader.RESET;
                lRecordRefFilter.GETTABLE(lRecPurchInvHeader);
                lFieldRefFilter := lRecordRefFilter.FIELD(lRecAdiutoSetup."Invoice Barcode Field No.");
                lFieldRefFilter.SETRANGE(FORMAT(lFieldRef.VALUE));
                IF NOT lRecordRefFilter.ISEMPTY THEN BEGIN
                    lRecordRefFilter.SETTABLE(lRecPurchInvHeader);
                    //<ADI-001
                    IF NOT CONFIRM(lCtx003, TRUE, lRecPurchInvHeader."No.") THEN
                        ERROR('');
                END;
            END;
        END;
    end;

    procedure CheckReturnReceipt(pRecSalesHeader: Record "Sales Header")
    var
        lRecAdiutoSetup: Record "Adiuto Setup ED";
        lCtx001: Label 'Barcode obbligatorio';
        lRecReturnReceiptHeader: Record "Return Receipt Header";
        lCtx002: Label 'Barcode già presente sulla spedizione reso nr. %1, vuoi continuare?';
        lCtx003: Label 'Barcode già presente sulla nota di credito nr. %1, vuoi continuare?';
        lRecordRef: RecordRef;
        lFieldRef: FieldRef;
        lFieldRefFilter: FieldRef;
        lRecordRefFilter: RecordRef;
    begin
        lRecAdiutoSetup.GET;
        IF NOT lRecAdiutoSetup.Enable THEN
            EXIT;

        IF pRecSalesHeader.Receive THEN BEGIN
            IF lRecAdiutoSetup."Mandatory Return Rcpt. Barcode" THEN BEGIN
                //>ADI-001
                //pRecSalesHeader.TESTFIELD("Barcode Delivery Document");

                lRecAdiutoSetup.TESTFIELD("Delivery Barcode Field No.");
                lRecordRef.GETTABLE(pRecSalesHeader);
                lFieldRef := lRecordRef.FIELD(lRecAdiutoSetup."Delivery Barcode Field No.");
                lFieldRef.TESTFIELD;
                //<ADI-001
            END;

            IF lRecAdiutoSetup."Check Return Rcpt. Duplicate" THEN BEGIN
                //>ADI-001
                //lRecReturnReceiptHeader.SETRANGE("Barcode Delivery Document",pRecSalesHeader."Barcode Delivery Document");
                //IF lRecReturnReceiptHeader.FIND('-') THEN BEGIN

                lRecAdiutoSetup.TESTFIELD("Delivery Barcode Field No.");
                lRecordRef.GETTABLE(pRecSalesHeader);
                lFieldRef := lRecordRef.FIELD(lRecAdiutoSetup."Delivery Barcode Field No.");

                lRecReturnReceiptHeader.RESET;
                lRecordRefFilter.GETTABLE(lRecReturnReceiptHeader);
                lFieldRefFilter := lRecordRefFilter.FIELD(lRecAdiutoSetup."Delivery Barcode Field No.");
                lFieldRefFilter.SETRANGE(FORMAT(lFieldRef.VALUE));
                IF NOT lRecordRefFilter.ISEMPTY THEN BEGIN
                    lRecordRefFilter.SETTABLE(lRecReturnReceiptHeader);
                    //<ADI-001
                    IF NOT CONFIRM(lCtx002, TRUE, lRecReturnReceiptHeader."No.") THEN
                        ERROR('');
                END;
            END;
        END;
    end;

    local procedure GetFileName(pRecAdiutoSetupDetail: Record "Adiuto Setup Detail ED"; pRefRecord: RecordRef) rTxtOutput: Text
    var
        lRecAdiutoSetupDetailLines: Record "Adiuto Setup Detail Lines ED";
        lFieldRef: FieldRef;
    begin
        rTxtOutput := '';
        lRecAdiutoSetupDetailLines.RESET;
        lRecAdiutoSetupDetailLines.SETRANGE("Primary Key", pRecAdiutoSetupDetail."Primary Key");
        lRecAdiutoSetupDetailLines.SETRANGE("Line No.", pRecAdiutoSetupDetail."Line No.");
        lRecAdiutoSetupDetailLines.SETRANGE("Use for Searching", TRUE);
        IF lRecAdiutoSetupDetailLines.FINDSET THEN BEGIN
            REPEAT
                lFieldRef := pRefRecord.FIELD(lRecAdiutoSetupDetailLines."NAV Field Id");
                rTxtOutput += FORMAT(lFieldRef.VALUE);
            UNTIL lRecAdiutoSetupDetailLines.NEXT = 0;
        END;
    end;

    local procedure GetFilePath(pTxtFileName: Text; pRecAdiutoSetupDetail: Record "Adiuto Setup Detail ED") rTxtOutput: Text
    var
        lIntPos: Integer;
        lTxtFileName: Text[250];
    begin
        rTxtOutput := '';
        lIntPos := STRPOS(pTxtFileName, '/');
        IF lIntPos > 0 THEN BEGIN
            REPEAT
                pTxtFileName := DELSTR(pTxtFileName, lIntPos, 1);
                lIntPos := STRPOS(pTxtFileName, '/');
            UNTIL lIntPos = 0;
        END;

        lTxtFileName := pTxtFileName + '.' + pRecAdiutoSetupDetail."File Extension";
        rTxtOutput := TEMPORARYPATH + lTxtFileName;
    end;

    local procedure Log(lRecAdiutoElectrInv: Record "Adiuto Electr. Doc."; pTxtOperation: Text; pTxtNote: Text)
    var
        lRecAdiutoElectrInvLog: Record "Adiuto Electr. Doc. Log";
    begin
        lRecAdiutoElectrInvLog.INIT;
        lRecAdiutoElectrInvLog."Entry No." := lRecAdiutoElectrInvLog.GetNextLineNo;
        lRecAdiutoElectrInvLog."User ID" := USERID;
        lRecAdiutoElectrInvLog."Source No." := lRecAdiutoElectrInv."Source No.";
        lRecAdiutoElectrInvLog."Document No." := lRecAdiutoElectrInv."Document No.";
        lRecAdiutoElectrInvLog.Barcode := lRecAdiutoElectrInv.IdUnivoco;
        lRecAdiutoElectrInvLog.Operation := pTxtOperation;
        lRecAdiutoElectrInvLog.Note := pTxtNote;
        lRecAdiutoElectrInvLog.INSERT(TRUE);
    end;

    procedure AdiutoPublishElectrInvoiceXmlFromVariant(RecordVariant: Variant)
    var
        lRefRecord: RecordRef;
        lRecAdiutoSetup: Record "Adiuto Setup ED";
        lFieldRef: FieldRef;
        lBlnVariationNote: Boolean;
    begin
        lRefRecord.GETTABLE(RecordVariant);
        lBlnVariationNote := FALSE;
        lRecAdiutoSetup.GET;
        IF lRecAdiutoSetup."Variation Note Field No." > 0 THEN BEGIN
            lFieldRef := lRefRecord.FIELD(lRecAdiutoSetup."Variation Note Field No.");
            lBlnVariationNote := lFieldRef.VALUE;
        END;
        IF lBlnVariationNote THEN
            AdiutoInsertVariationNoteFromVariantRec(RecordVariant)
        ELSE
            AdiutoPublishElectrInvoiceXML(lRefRecord);
    end;

    procedure AdiutoPublishElectrInvoiceXML(var pRecRef: RecordRef) rBlnOutput: Boolean
    var
        lRecSalesInvHeader: Record "Sales Invoice Header";
        lRecSalesCrMemoHeader: Record "Sales Cr.Memo Header";
        lRecServiceInvHeader: Record "Service Invoice Header";
        lRecServiceCrMemoHeader: Record "Service Cr.Memo Header";
        //UPDATE
        lTmpRecAdiutoElectrDoc: Record "Adiuto Electr. Doc." temporary;

    begin
        rBlnOutput := FALSE;
        //UPDATE
        lTmpRecAdiutoElectrDoc.DeleteAll();
        lTmpRecAdiutoElectrDoc.Init();
        CASE pRecRef.NUMBER OF
            DATABASE::"Sales Invoice Header":
                BEGIN
                    pRecRef.SETTABLE(lRecSalesInvHeader);
                    //TODO              lRecSalesInvHeader.TESTFIELD("PA-Electronic Document Filen.");
                    //TODO              lRecSalesInvHeader.CALCFIELDS(lRecSalesInvHeader."PA-E-Document XML");
                    //TODO              lRecSalesInvHeader.TESTFIELD(lRecSalesInvHeader."PA-E-Document XML");

                    //TODO              PublishElectrInvXMLFromBLOB(lRecSalesInvHeader, lRecSalesInvHeader."PA-E-Document XML", lRecSalesInvHeader."PA-Electronic Document Filen.");
                END;
            DATABASE::"Sales Cr.Memo Header":
                BEGIN
                    pRecRef.SETTABLE(lRecSalesCrMemoHeader);
                    //TODO              lRecSalesCrMemoHeader.TESTFIELD("PA-Electronic Document Filen.");
                    //TODO              lRecSalesCrMemoHeader.CALCFIELDS(lRecSalesCrMemoHeader."PA-E-Document XML");
                    //TODO              lRecSalesCrMemoHeader.TESTFIELD(lRecSalesCrMemoHeader."PA-E-Document XML");

                    //TODO              PublishElectrInvXMLFromBLOB(lRecSalesCrMemoHeader, lRecSalesCrMemoHeader."PA-E-Document XML", lRecSalesCrMemoHeader."PA-Electronic Document Filen.");
                END;
            DATABASE::"Service Invoice Header":
                BEGIN
                    pRecRef.SETTABLE(lRecServiceInvHeader);
                    //TODO              lRecServiceInvHeader.TESTFIELD("PA-Electronic Document Filen.");
                    //TODO              lRecServiceInvHeader.CALCFIELDS(lRecServiceInvHeader."PA-E-Document XML");
                    //TODO              lRecServiceInvHeader.TESTFIELD(lRecServiceInvHeader."PA-E-Document XML");

                    //TODO              PublishElectrInvXMLFromBLOB(lRecServiceInvHeader, lRecServiceInvHeader."PA-E-Document XML", lRecServiceInvHeader."PA-Electronic Document Filen.");
                END;
            DATABASE::"Service Cr.Memo Header":
                BEGIN
                    pRecRef.SETTABLE(lRecServiceCrMemoHeader);
                    //TODO              lRecServiceCrMemoHeader.TESTFIELD("PA-Electronic Document Filen.");
                    //TODO              lRecServiceCrMemoHeader.CALCFIELDS(lRecServiceCrMemoHeader."PA-E-Document XML");
                    //TODO              lRecServiceCrMemoHeader.TESTFIELD(lRecServiceCrMemoHeader."PA-E-Document XML");

                    //TODO              PublishElectrInvXMLFromBLOB(lRecServiceCrMemoHeader, lRecServiceCrMemoHeader."PA-E-Document XML", lRecServiceCrMemoHeader."PA-Electronic Document Filen.");
                END;
        END;
    end;

    procedure AdiutoPublishElectrXmlFromVariantAndPath(RecordVariant: Variant; pTxtXmlPath: Text)
    var
        lRefRecord: RecordRef;
        lRecAdiutoSetup: Record "Adiuto Setup ED";
        lFieldRef: FieldRef;
        lBlnVariationNote: Boolean;
    begin
        lRefRecord.GETTABLE(RecordVariant);
        lBlnVariationNote := FALSE;
        IF lRecAdiutoSetup."Variation Note Field No." > 0 THEN BEGIN
            lFieldRef := lRefRecord.FIELD(lRecAdiutoSetup."Variation Note Field No.");
            lBlnVariationNote := lFieldRef.VALUE;
        END;
        IF lBlnVariationNote THEN
            AdiutoInsertVariationNoteFromVariantRec(RecordVariant)
        ELSE
            PublishElectrInvXMLFromPath(RecordVariant, pTxtXmlPath);
    end;

    procedure AdiutoPublishElectrXmlFromRecordIDAndPath(pTxtFilePath: Text; RecordID: RecordID)
    var
        SalesInvHeader: Record "Sales Invoice Header";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        ServiceInvHeader: Record "Service Invoice Header";
        ServiceCrMemoHeader: Record "Service Cr.Memo Header";
        HeaderRecRef: RecordRef;
    begin

        CASE RecordID.TABLENO OF
            DATABASE::"Sales Invoice Header":
                BEGIN
                    HeaderRecRef := RecordID.GETRECORD;
                    HeaderRecRef.SETTABLE(SalesInvHeader);
                    IF SalesInvHeader.GET(SalesInvHeader."No.") THEN BEGIN
                        PublishElectrInvXMLFromPath(SalesInvHeader, pTxtFilePath);
                    END;
                END;
            DATABASE::"Service Invoice Header":
                BEGIN
                    HeaderRecRef := RecordID.GETRECORD;
                    HeaderRecRef.SETTABLE(ServiceInvHeader);
                    IF SalesInvHeader.GET(ServiceInvHeader."No.") THEN BEGIN
                        PublishElectrInvXMLFromPath(ServiceInvHeader, pTxtFilePath);
                    END;
                END;
            DATABASE::"Sales Cr.Memo Header":
                BEGIN
                    HeaderRecRef := RecordID.GETRECORD;
                    HeaderRecRef.SETTABLE(SalesCrMemoHeader);
                    IF SalesCrMemoHeader.GET(SalesCrMemoHeader."No.") THEN BEGIN
                        PublishElectrInvXMLFromPath(SalesCrMemoHeader, pTxtFilePath);
                    END;
                END;
            DATABASE::"Service Cr.Memo Header":
                BEGIN
                    HeaderRecRef := RecordID.GETRECORD;
                    HeaderRecRef.SETTABLE(ServiceCrMemoHeader);
                    IF ServiceCrMemoHeader.GET(ServiceCrMemoHeader."No.") THEN BEGIN
                        PublishElectrInvXMLFromPath(ServiceCrMemoHeader, pTxtFilePath);
                    END;
                END;
        END;
    end;

    procedure AdiutoInsertVariationNoteFromVariantRec(RecordVariant: Variant)
    var
        lRecAdiutoSetup: Record "Adiuto Setup ED";
        lRecAdiutoSetupDetail: Record "Adiuto Setup Detail ED";
        lRecAdiutoSetupDetailLines: Record "Adiuto Setup Detail Lines ED";
        lRefRecord: RecordRef;
        lFieldRef: FieldRef;
        lText: Text;
        Convert: DotNet Convert;
        ClientFile: DotNet File;
        lCduFileManagement: Codeunit "File Management";
        lTxtFilePath: Text;
        lTxtFileContent: Text;
        lTxtFileName: Text;
    begin
        lRecAdiutoSetup.GET;
        IF NOT lRecAdiutoSetup.Enable THEN
            EXIT;

        lRefRecord.GETTABLE(RecordVariant);

        lRecAdiutoSetupDetail.RESET;
        lRecAdiutoSetupDetail.SETRANGE("Primary Key", lRecAdiutoSetup."Primary Key");
        lRecAdiutoSetupDetail.SETRANGE("Table Id", lRefRecord.NUMBER);
        lRecAdiutoSetupDetail.SETRANGE("XML Document", lRecAdiutoSetupDetail."XML Document"::"Variation Note");
        //lRecAdiutoSetupDetail.SETRANGE("Create Document",TRUE);
        lRecAdiutoSetupDetail.SETRANGE(Canceled, FALSE);
        IF lRecAdiutoSetupDetail.FINDFIRST THEN BEGIN
            lText := GetFileName(lRecAdiutoSetupDetail, lRefRecord);
            lTxtFilePath := GetFilePath(lText, lRecAdiutoSetupDetail);

            IF lRecAdiutoSetupDetail."El. Doc. Att. Rpt. Setup Code" = '' THEN
                REPORT.SAVEASPDF(lRecAdiutoSetupDetail."Report Id", lTxtFilePath, RecordVariant)
            ELSE BEGIN
                OnBeforeReportPrint(RecordVariant, lRecAdiutoSetupDetail."Report Id", lRecAdiutoSetupDetail."El. Doc. Att. Rpt. Setup Code");
                REPORT.SAVEASPDF(lRecAdiutoSetupDetail."Report Id", lTxtFilePath);
            END;

            lTxtFileContent := Convert.ToBase64String(ClientFile.ReadAllBytes(lTxtFilePath));
            lTxtFileName := lCduFileManagement.GetFileName(lTxtFilePath);

            gCduAdiutoNetWebService.InsertDocument(lTxtFileName, lTxtFileContent, lRecAdiutoSetupDetail, lRefRecord);

            IF lRecAdiutoSetupDetail."El. Doc. Attachment Report Id" > 0 THEN
                InsertDocFromVariantRec(lRecAdiutoSetupDetail."El. Doc. Attachment Report Id", RecordVariant);
        END;
    end;

    procedure AdiutoGetPublishedStatus(pVarRecord: Variant)
    var
        lRecAdiutoSetup: Record "Adiuto Setup ED";
        lRecAdiutoSetupDetail: Record "Adiuto Setup Detail ED";
        lRecAdiutoElectrInv: Record "Adiuto Electr. Doc.";
        lRefRecord: RecordRef;
        lTxtStatus: Text;
    begin

        lRefRecord.GETTABLE(pVarRecord);
        IF NOT lRecAdiutoElectrInv.GET(lRefRecord.NUMBER, ElectrInvGetRecDocumentNo(lRefRecord), ElectrInvGetRecIdUnivoco(lRefRecord)) THEN
            EXIT;

        lRecAdiutoSetupDetail.RESET;
        lRecAdiutoSetupDetail.SETRANGE("Primary Key", lRecAdiutoSetup."Primary Key");
        lRecAdiutoSetupDetail.SETRANGE("Table Id", lRecAdiutoElectrInv."Source No.");
        lRecAdiutoSetupDetail.SETRANGE("XML Document", lRecAdiutoSetupDetail."XML Document"::"Active XML");
        //lRecAdiutoSetupDetail.SETRANGE("Create Document",TRUE);
        lRecAdiutoSetupDetail.SETRANGE(Canceled, FALSE);
        IF NOT lRecAdiutoSetupDetail.FINDFIRST THEN
            EXIT;

        lTxtStatus := gCduAdiutoNetWebService.ElectrInvoiceGetStatus(lRecAdiutoSetupDetail, lRefRecord);
        Log(lRecAdiutoElectrInv, 'Check Status', lTxtStatus);
        IF lTxtStatus <> '' THEN
            ElectInvUpdateStatus(pVarRecord, lTxtStatus);
    end;

    local procedure ElectrInvGetRecDocumentNo(var pRecRef: RecordRef) rCodDocumentNo: Code[20]
    var
        lRecSalesInvHeader: Record "Sales Invoice Header";
        lRecSalesCrMemoHeader: Record "Sales Cr.Memo Header";
        lRecServiceInvHeader: Record "Service Invoice Header";
        lRecServiceCrMemoHeader: Record "Service Cr.Memo Header";
    begin
        rCodDocumentNo := '';
        CASE pRecRef.NUMBER OF
            DATABASE::"Sales Invoice Header":
                BEGIN
                    pRecRef.SETTABLE(lRecSalesInvHeader);
                    rCodDocumentNo := lRecSalesInvHeader."No.";
                END;
            DATABASE::"Sales Cr.Memo Header":
                BEGIN
                    pRecRef.SETTABLE(lRecSalesCrMemoHeader);
                    rCodDocumentNo := lRecSalesCrMemoHeader."No.";
                END;
            DATABASE::"Service Invoice Header":
                BEGIN
                    pRecRef.SETTABLE(lRecServiceInvHeader);
                    rCodDocumentNo := lRecServiceInvHeader."No.";
                END;
            DATABASE::"Service Cr.Memo Header":
                BEGIN
                    pRecRef.SETTABLE(lRecServiceCrMemoHeader);
                    rCodDocumentNo := lRecServiceCrMemoHeader."No.";
                END;
        END;
    end;

    local procedure ElectrInvGetRecIdUnivoco(var pRecRef: RecordRef) rCodBarcode: Code[20]
    var
        lRecSalesInvHeader: Record "Sales Invoice Header";
        lRecSalesCrMemoHeader: Record "Sales Cr.Memo Header";
        lRecServiceInvHeader: Record "Service Invoice Header";
        lRecServiceCrMemoHeader: Record "Service Cr.Memo Header";
        lRecAdiutoElectrInv: Record "Adiuto Electr. Doc.";
    begin
        rCodBarcode := '';
        CASE pRecRef.NUMBER OF
            DATABASE::"Sales Invoice Header":
                BEGIN
                    pRecRef.SETTABLE(lRecSalesInvHeader);
                    //rCodDocumentNo:=lRecSalesInvHeader."No.";
                END;
            DATABASE::"Sales Cr.Memo Header":
                BEGIN
                    pRecRef.SETTABLE(lRecSalesCrMemoHeader);
                    //rCodDocumentNo:=lRecSalesCrMemoHeader."No.";
                END;
            DATABASE::"Service Invoice Header":
                BEGIN
                    pRecRef.SETTABLE(lRecServiceInvHeader);
                    //rCodDocumentNo:=lRecServiceInvHeader."No.";
                END;
            DATABASE::"Service Cr.Memo Header":
                BEGIN
                    pRecRef.SETTABLE(lRecServiceCrMemoHeader);
                    //rCodDocumentNo:=lRecServiceCrMemoHeader.;
                END;
            DATABASE::"Adiuto Electr. Doc.":
                BEGIN
                    pRecRef.SETTABLE(lRecAdiutoElectrInv);
                    rCodBarcode := lRecAdiutoElectrInv.IdUnivoco;
                END;
        END;
    end;

    local procedure ElectrInvGetRecFileName(var pRecRef: RecordRef) rTxtFileName: Text
    var
        lRecSalesInvHeader: Record "Sales Invoice Header";
        lRecSalesCrMemoHeader: Record "Sales Cr.Memo Header";
        lRecServiceInvHeader: Record "Service Invoice Header";
        lRecServiceCrMemoHeader: Record "Service Cr.Memo Header";
        lRecAdiutoElectrInv: Record "Adiuto Electr. Doc.";
    begin
        rTxtFileName := '';
        CASE pRecRef.NUMBER OF
            DATABASE::"Sales Invoice Header":
                BEGIN
                    pRecRef.SETTABLE(lRecSalesInvHeader);
                    //TODO              rTxtFileName:=lRecSalesInvHeader."PA-Electronic Document Filen.";
                END;
            DATABASE::"Sales Cr.Memo Header":
                BEGIN
                    pRecRef.SETTABLE(lRecSalesCrMemoHeader);
                    //TODO              rTxtFileName:=lRecSalesCrMemoHeader."PA-Electronic Document Filen.";
                END;
            DATABASE::"Service Invoice Header":
                BEGIN
                    pRecRef.SETTABLE(lRecServiceInvHeader);
                    //TODO              rTxtFileName:=lRecServiceInvHeader."PA-Electronic Document Filen.";
                END;
            DATABASE::"Service Cr.Memo Header":
                BEGIN
                    pRecRef.SETTABLE(lRecServiceCrMemoHeader);
                    //TODO              rTxtFileName:=lRecServiceCrMemoHeader."PA-Electronic Document Filen.";
                END;
            DATABASE::"Adiuto Electr. Doc.":
                BEGIN
                    pRecRef.SETTABLE(lRecAdiutoElectrInv);
                    rTxtFileName := lRecAdiutoElectrInv."File Name";
                END;
        END;
    end;

    local procedure ElectrInvGetRecBarcode(var pRecRef: RecordRef) rCodBarcode: Code[50]
    var
        lRecSalesInvHeader: Record "Sales Invoice Header";
        lRecSalesCrMemoHeader: Record "Sales Cr.Memo Header";
        lRecServiceInvHeader: Record "Service Invoice Header";
        lRecServiceCrMemoHeader: Record "Service Cr.Memo Header";
        lRecAdiutoElectrInv: Record "Adiuto Electr. Doc.";
    begin
        rCodBarcode := '';
        CASE pRecRef.NUMBER OF
            DATABASE::"Sales Invoice Header":
                BEGIN
                    pRecRef.SETTABLE(lRecSalesInvHeader);
                    //rCodDocumentNo:=lRecSalesInvHeader."No.";
                END;
            DATABASE::"Sales Cr.Memo Header":
                BEGIN
                    pRecRef.SETTABLE(lRecSalesCrMemoHeader);
                    //rCodDocumentNo:=lRecSalesCrMemoHeader."No.";
                END;
            DATABASE::"Service Invoice Header":
                BEGIN
                    pRecRef.SETTABLE(lRecServiceInvHeader);
                    //rCodDocumentNo:=lRecServiceInvHeader."No.";
                END;
            DATABASE::"Service Cr.Memo Header":
                BEGIN
                    pRecRef.SETTABLE(lRecServiceCrMemoHeader);
                    //rCodDocumentNo:=lRecServiceCrMemoHeader.;
                END;
            DATABASE::"Adiuto Electr. Doc.":
                BEGIN
                    pRecRef.SETTABLE(lRecAdiutoElectrInv);
                    rCodBarcode := lRecAdiutoElectrInv.Barcode;
                END;
        END;
    end;

    local procedure ElectrInvCreateAC(pVarRecord: Variant; pTxtFilePath: Text) rBlnOutput: Boolean
    var
        lRecAdiutoSetup: Record "Adiuto Setup ED";
        lRefRecord: RecordRef;
        lRecAdiutoElectrInv: Record "Adiuto Electr. Doc.";
        lCduFileManagement: Codeunit "File Management";
        lOutStream: OutStream;
        TextEncoding: DotNet Encoding;
        ClientFile: DotNet File;
        streamWriter: DotNet StreamWriter;
        Convert: DotNet Convert;
    begin
        lRecAdiutoSetup.GET;
        IF NOT lRecAdiutoSetup.Enable THEN
            EXIT;

        lRefRecord.GETTABLE(pVarRecord);
        IF lRecAdiutoElectrInv.GET(lRefRecord.NUMBER, ElectrInvGetRecDocumentNo(lRefRecord), ElectrInvGetRecIdUnivoco(lRefRecord)) THEN BEGIN
            IF NOT lRecAdiutoSetup."Multiple Publish" THEN
                EXIT;
            lRecAdiutoElectrInv."File Name" := lCduFileManagement.GetFileName(pTxtFilePath);
            //DEPRECATED: lRecAdiutoElectrInv."File Content".IMPORT(pTxtFilePath, FALSE);
            lRecAdiutoElectrInv."File Content".CREATEOUTSTREAM(lOutStream);
            streamWriter := streamWriter.StreamWriter(lOutStream, TextEncoding.UTF8);
            streamWriter.Write((ClientFile.ReadAllText(pTxtFilePath)));
            streamWriter.Close;
            lRecAdiutoElectrInv.Status := lRecAdiutoSetup."Electr. Doc. Start Status";
            rBlnOutput := lRecAdiutoElectrInv.MODIFY;
            Log(lRecAdiutoElectrInv, 'Update Record', 'ElectrInvCreateAC');
        END
        ELSE BEGIN
            lRecAdiutoElectrInv.INIT;
            lRecAdiutoElectrInv."Source No." := lRefRecord.NUMBER;
            lRecAdiutoElectrInv."Document No." := ElectrInvGetRecDocumentNo(lRefRecord);
            lRecAdiutoElectrInv.IdUnivoco := ElectrInvGetRecIdUnivoco(lRefRecord);
            lRecAdiutoElectrInv."File Name" := lCduFileManagement.GetFileName(pTxtFilePath);
            //DEPRECATED: lRecAdiutoElectrInv."File Content".IMPORT(pTxtFilePath, FALSE);
            lRecAdiutoElectrInv."File Content".CREATEOUTSTREAM(lOutStream);
            streamWriter := streamWriter.StreamWriter(lOutStream, TextEncoding.UTF8);
            streamWriter.Write((ClientFile.ReadAllText(pTxtFilePath)));
            streamWriter.Close;
            lRecAdiutoElectrInv.Status := lRecAdiutoSetup."Electr. Doc. Start Status";
            rBlnOutput := lRecAdiutoElectrInv.INSERT;
            Log(lRecAdiutoElectrInv, 'Create Record', 'ElectrInvCreateAC');
        END;
    end;

    //UPDATE    local procedure ElectrInvCreateACFromBLOB(pVarRecord: Variant; pBlbFileContent: Variant; pTxtFileName: Text) rBlnOutput: Boolean
    local procedure ElectrInvCreateACFromBLOB(pVarRecord: Variant; pRecAdiutoElecrtDoc: Record "Adiuto Electr. Doc." temporary; pTxtFileName: Text) rBlnOutput: Boolean
    var
        lRecAdiutoSetup: Record "Adiuto Setup ED";
        lRefRecord: RecordRef;
        lRecAdiutoElectrInv: Record "Adiuto Electr. Doc.";
        lCduFileManagement: Codeunit "File Management";
        ClientFile: DotNet File;
    begin
        lRecAdiutoSetup.GET;
        IF NOT lRecAdiutoSetup.Enable THEN
            EXIT;

        lRefRecord.GETTABLE(pVarRecord);


        lRefRecord.GETTABLE(pVarRecord);
        IF lRecAdiutoElectrInv.GET(lRefRecord.NUMBER, ElectrInvGetRecDocumentNo(lRefRecord), ElectrInvGetRecIdUnivoco(lRefRecord)) THEN BEGIN
            IF NOT lRecAdiutoSetup."Multiple Publish" THEN
                EXIT;
            lRecAdiutoElectrInv."File Name" := ElectrInvGetRecFileName(lRefRecord); // pTxtFileName;
            //UPDATE            lRecAdiutoElectrInv."File Content" := pBlbFileContent;
            pRecAdiutoElecrtDoc.CalcFields(pRecAdiutoElecrtDoc."File Content");
            lRecAdiutoElectrInv."File Content" := pRecAdiutoElecrtDoc."File Content";
            lRecAdiutoElectrInv.Status := lRecAdiutoSetup."Electr. Doc. Start Status";
            rBlnOutput := lRecAdiutoElectrInv.MODIFY;
            Log(lRecAdiutoElectrInv, 'Update Record', 'ElectrInvCreateACFromBLOB');
        END
        ELSE BEGIN
            lRecAdiutoElectrInv.INIT;
            lRecAdiutoElectrInv."Source No." := lRefRecord.NUMBER;
            lRecAdiutoElectrInv."Document No." := ElectrInvGetRecDocumentNo(lRefRecord);
            lRecAdiutoElectrInv.IdUnivoco := ElectrInvGetRecIdUnivoco(lRefRecord);
            lRecAdiutoElectrInv."File Name" := ElectrInvGetRecFileName(lRefRecord); // pTxtFileName;
            //UPDATE            lRecAdiutoElectrInv."File Content" := pBlbFileContent;
            pRecAdiutoElecrtDoc.CalcFields(pRecAdiutoElecrtDoc."File Content");
            lRecAdiutoElectrInv."File Content" := pRecAdiutoElecrtDoc."File Content";
            lRecAdiutoElectrInv.Status := lRecAdiutoSetup."Electr. Doc. Start Status";
            rBlnOutput := lRecAdiutoElectrInv.INSERT;
            Log(lRecAdiutoElectrInv, 'Create Record', 'ElectrInvCreateACFromBLOB');
        END;
    end;

    local procedure GetBinaryContentFromFileContent(lRecAdiutoElectrInv: Record "Adiuto Electr. Doc."; var pTxtContentText: Text) rTxtOutput: Text
    var
        Convert: DotNet Convert;
        lCduFileManagement: Codeunit "File Management";
        lTxtFilePath: Text;
        ClientFile: DotNet File;
        InStream: InStream;
        Buffer: Text;
        TextEncoding: DotNet Encoding;
        streamReader: DotNet StreamReader;
    begin
        pTxtContentText := '';
        lRecAdiutoElectrInv.CALCFIELDS("File Content");
        lRecAdiutoElectrInv."File Content".CREATEINSTREAM(InStream);
        streamReader := streamReader.StreamReader(InStream, TextEncoding.UTF8, TRUE);
        Buffer := streamReader.ReadToEnd();
        pTxtContentText := Buffer;
        lTxtFilePath := lCduFileManagement.ServerTempFileName('txt');
        IF EXISTS(lTxtFilePath) THEN
            IF NOT ERASE(lTxtFilePath) THEN
                ERROR('Impossibile eliminare il file "' + lTxtFilePath + '"');

        ClientFile.WriteAllText(lTxtFilePath, Buffer);
        rTxtOutput := Convert.ToBase64String(ClientFile.ReadAllBytes(lTxtFilePath));
    end;

    local procedure InsertDocForElectrInvoice(pVarRecord: Variant) rIntOutput: Integer
    var
        lRecAdiutoSetup: Record "Adiuto Setup ED";
        lRecAdiutoSetupDetail: Record "Adiuto Setup Detail ED";
        lTxtFileName: Text;
        lTxtFileContent: Text;
        lRecAdiutoElectrInv: Record "Adiuto Electr. Doc.";
        lRefRecord: RecordRef;
        lCduAdiutoEDManagement: Codeunit "Adiuto ED Management";
        lTxtContentText: Text;
        Convert: DotNet Convert;
        lTxtTransmit: Text;
        lTxtProgressive: Text;
        lTxtVATRegNo: Text;
        lTxtCustCompName: Text;
    begin
        lRecAdiutoSetup.GET;
        //se non abilitato non eseguo le funzioni di adiuto
        IF NOT lRecAdiutoSetup.Enable THEN
            EXIT;

        lRefRecord.GETTABLE(pVarRecord);
        IF NOT lRecAdiutoElectrInv.GET(lRefRecord.NUMBER, ElectrInvGetRecDocumentNo(lRefRecord), ElectrInvGetRecIdUnivoco(lRefRecord)) THEN
            EXIT;

        IF lRecAdiutoElectrInv.Status <> lRecAdiutoSetup."Electr. Doc. Start Status" THEN
            EXIT;

        lRecAdiutoSetupDetail.RESET;
        lRecAdiutoSetupDetail.SETRANGE("Primary Key", lRecAdiutoSetup."Primary Key");
        lRecAdiutoSetupDetail.SETRANGE("Table Id", lRecAdiutoElectrInv."Source No.");
        lRecAdiutoSetupDetail.SETRANGE("XML Document", lRecAdiutoSetupDetail."XML Document"::"Active XML");
        //lRecAdiutoSetupDetail.SETRANGE("Create Document",TRUE);
        lRecAdiutoSetupDetail.SETRANGE(Canceled, FALSE);
        IF NOT lRecAdiutoSetupDetail.FINDFIRST THEN
            EXIT;

        IF lRecAdiutoSetupDetail."El. Doc. Attachment Report Id" > 0 THEN
            InsertDocFromVariantRec(lRecAdiutoSetupDetail."El. Doc. Attachment Report Id", pVarRecord);

        lTxtFileName := lRecAdiutoElectrInv."File Name";
        lTxtFileContent := GetBinaryContentFromFileContent(lRecAdiutoElectrInv, lTxtContentText);

        lTxtTransmit := lCduAdiutoEDManagement.GetXmlTagValueFromFileText(lTxtContentText,
          'p:FatturaElettronica/FatturaElettronicaHeader/DatiTrasmissione/IdTrasmittente/IdPaese');
        lTxtTransmit += lCduAdiutoEDManagement.GetXmlTagValueFromFileText(lTxtContentText,
          'p:FatturaElettronica/FatturaElettronicaHeader/DatiTrasmissione/IdTrasmittente/IdCodice');

        lTxtProgressive := lCduAdiutoEDManagement.GetXmlTagValueFromFileText(lTxtContentText,
          'p:FatturaElettronica/FatturaElettronicaHeader/DatiTrasmissione/ProgressivoInvio');

        lTxtVATRegNo := lCduAdiutoEDManagement.GetXmlTagValueFromFileText(lTxtContentText,
          'p:FatturaElettronica/FatturaElettronicaHeader/CedentePrestatore/DatiAnagrafici/IdFiscaleIVA/IdPaese');
        lTxtVATRegNo += lCduAdiutoEDManagement.GetXmlTagValueFromFileText(lTxtContentText,
          'p:FatturaElettronica/FatturaElettronicaHeader/CedentePrestatore/DatiAnagrafici/IdFiscaleIVA/IdCodice');

        lTxtCustCompName := lCduAdiutoEDManagement.GetXmlTagValueFromFileText(lTxtContentText,
          'p:FatturaElettronica/FatturaElettronicaHeader/CessionarioCommittente/DatiAnagrafici/Anagrafica/Denominazione');

        rIntOutput := gCduAdiutoNetWebService.InsertDocumentForElectrInvoice(lTxtFileName, lTxtFileContent, lRecAdiutoSetupDetail, lRefRecord, lTxtTransmit, lTxtVATRegNo, lTxtProgressive, lTxtCustCompName);
    end;

    local procedure ModifyDocForElectrInvoice(pVarRecord: Variant; pIntDocId: Integer)
    var
        lRecAdiutoSetup: Record "Adiuto Setup ED";
        lRecAdiutoSetupDetail: Record "Adiuto Setup Detail ED";
        lReiRecordID: RecordID;
        lIntPos: Integer;
        lTxtFileName: Text;
        lTxtFileContent: Text;
        lRecAdiutoElectrInv: Record "Adiuto Electr. Doc.";
        lRefRecord: RecordRef;
    begin
        lRecAdiutoSetup.GET;
        //se non abilitato non eseguo le funzioni di adiuto
        IF NOT lRecAdiutoSetup.Enable THEN
            EXIT;

        lRefRecord.GETTABLE(pVarRecord);
        IF NOT lRecAdiutoElectrInv.GET(lRefRecord.NUMBER, ElectrInvGetRecDocumentNo(lRefRecord), ElectrInvGetRecIdUnivoco(lRefRecord)) THEN
            EXIT;

        lRecAdiutoSetupDetail.RESET;
        lRecAdiutoSetupDetail.SETRANGE("Primary Key", lRecAdiutoSetup."Primary Key");
        lRecAdiutoSetupDetail.SETRANGE("Table Id", lRecAdiutoElectrInv."Source No.");
        lRecAdiutoSetupDetail.SETRANGE("XML Document", lRecAdiutoSetupDetail."XML Document"::"Active XML");
        lRecAdiutoSetupDetail.SETRANGE(Canceled, FALSE);
        IF NOT lRecAdiutoSetupDetail.FINDFIRST THEN
            EXIT;

        IF pIntDocId = 0 THEN
            EVALUATE(pIntDocId, gCduAdiutoNetWebService.GetDocId(lRecAdiutoSetupDetail, lRefRecord));

        gCduAdiutoNetWebService.ElectrInvoiceModifyDoc(pIntDocId, lRecAdiutoSetupDetail, lRecAdiutoElectrInv);
    end;

    //UPDATE    local procedure PublishElectrInvXMLFromBLOB(pVarRecord: Variant; pBlbFileContent: Variant; pTxtFileName: Text)
    local procedure PublishElectrInvXMLFromBLOB(pVarRecord: Variant; VAR pRecAdiutoElecrtDoc: Record "Adiuto Electr. Doc." temporary; pTxtFileName: Text)
    var
        lRecAdiutoSetup: Record "Adiuto Setup ED";
        lIntDocId: Integer;
    begin
        lRecAdiutoSetup.GET;
        //se non abilitato non eseguo le funzioni di adiuto
        IF NOT lRecAdiutoSetup.Enable THEN
            EXIT;

        IF ElectrInvCreateACFromBLOB(pVarRecord, pRecAdiutoElecrtDoc, pTxtFileName) THEN BEGIN
            lIntDocId := InsertDocForElectrInvoice(pVarRecord);
            IF lIntDocId > 0 THEN BEGIN
                ElectInvUpdateStatus(pVarRecord, lRecAdiutoSetup."Electr. Doc. Publish Status");
                ModifyDocForElectrInvoice(pVarRecord, lIntDocId);
            END;
        END;
    end;

    local procedure PublishElectrInvXMLFromPath(pVarRecord: Variant; pTxtFilePath: Text)
    var
        lRecAdiutoSetup: Record "Adiuto Setup ED";
        lIntDocId: Integer;
    begin
        lRecAdiutoSetup.GET;
        //se non abilitato non eseguo le funzioni di adiuto
        IF NOT lRecAdiutoSetup.Enable THEN
            EXIT;

        IF ElectrInvCreateAC(pVarRecord, pTxtFilePath) THEN BEGIN
            lIntDocId := InsertDocForElectrInvoice(pVarRecord);
            IF lIntDocId > 0 THEN BEGIN
                ElectInvUpdateStatus(pVarRecord, lRecAdiutoSetup."Electr. Doc. Publish Status");
                ModifyDocForElectrInvoice(pVarRecord, lIntDocId);
            END;
        END;
    end;

    local procedure ElectInvUpdateStatus(pVarRecord: Variant; pNewStatus: Text)
    var
        lRecAdiutoElectrInv: Record "Adiuto Electr. Doc.";
        lRefRecord: RecordRef;
    begin
        lRefRecord.GETTABLE(pVarRecord);
        IF lRecAdiutoElectrInv.GET(lRefRecord.NUMBER, ElectrInvGetRecDocumentNo(lRefRecord), ElectrInvGetRecIdUnivoco(lRefRecord)) THEN BEGIN
            lRecAdiutoElectrInv.VALIDATE(Status, pNewStatus);
            lRecAdiutoElectrInv.MODIFY;
        END;
    end;

    procedure AdiutoElectrInvoiceDownloadAll(pBlnShowMessage: Boolean) rIntOutput: Integer
    var
        lRecAdiutoSetupDetail: Record "Adiuto Setup Detail ED";
        Text001: Label 'Imported %1 documents from Adiuto';
    begin
        rIntOutput := 0;
        lRecAdiutoSetupDetail.RESET;
        lRecAdiutoSetupDetail.SETRANGE("XML Document", lRecAdiutoSetupDetail."XML Document"::"Passive XML");
        IF lRecAdiutoSetupDetail.FINDSET THEN BEGIN
            REPEAT
                rIntOutput += AdiutoElectrInvoiceDownloadXML(lRecAdiutoSetupDetail);
            UNTIL lRecAdiutoSetupDetail.NEXT = 0;
        END;
        IF pBlnShowMessage THEN
            MESSAGE(STRSUBSTNO(Text001, FORMAT(rIntOutput)));
    end;

    procedure AdiutoElectrInvoiceDownloadXML(pRecAdiutoSetupDetail: Record "Adiuto Setup Detail ED") rIntOutput: Integer
    var
        lTxtFilePath: Text;
        lIntDocId: Integer;
        lRecAdiutoSetup: Record "Adiuto Setup ED";
        lRefRecord: RecordRef;
        lTmpRecAdiutoElectrInv: Record "Adiuto Electr. Doc." temporary;
        lRecAdiutoElectrInv: Record "Adiuto Electr. Doc.";
    begin
        rIntOutput := 0;
        lRecAdiutoSetup.GET;
        IF NOT lRecAdiutoSetup.Enable THEN
            EXIT;

        lTmpRecAdiutoElectrInv.DELETEALL;
        gCduAdiutoNetWebService.ElectrInvoiceGetDocuments(pRecAdiutoSetupDetail, lTmpRecAdiutoElectrInv);
        IF lTmpRecAdiutoElectrInv.FINDSET THEN BEGIN
            REPEAT
                EVALUATE(lIntDocId, lTmpRecAdiutoElectrInv.IdUnivoco);
                CASE lRecAdiutoSetup."Electr. Doc. signed xml" OF
                    lRecAdiutoSetup."Electr. Doc. signed xml"::Xades:
                        lTxtFilePath := gCduAdiutoNetWebService.GetLargeContentXades(lIntDocId, pRecAdiutoSetupDetail."File Extension", '1', '0');
                    ELSE
                        lTxtFilePath := gCduAdiutoNetWebService.GetLargeContentExt(lIntDocId, pRecAdiutoSetupDetail."File Extension");
                END;
                IF ElectrInvCreatePCFromVariant(lTmpRecAdiutoElectrInv, lTxtFilePath, pRecAdiutoSetupDetail) THEN BEGIN
                    lRefRecord.GETTABLE(lTmpRecAdiutoElectrInv);
                    IF lRecAdiutoElectrInv.GET(lRefRecord.NUMBER, ElectrInvGetRecDocumentNo(lRefRecord), ElectrInvGetRecIdUnivoco(lRefRecord)) THEN
                        gCduAdiutoNetWebService.ElectrInvoiceModifyDoc(lIntDocId, pRecAdiutoSetupDetail, lRecAdiutoElectrInv);
                    rIntOutput += 1;
                    //>JM-FM20190416
                    COMMIT;
                    //>JM-FM20190416
                END;
            UNTIL lTmpRecAdiutoElectrInv.NEXT = 0;
        END;
    end;

    procedure AdiutoElectrInvoiceSaveFileXML()
    var
        lRecAdiutoSetup: Record "Adiuto Setup ED";
        lRecAdiutoElectrInv: Record "Adiuto Electr. Doc.";
        lCduFileManagement: Codeunit "File Management";
        Text001: Label 'Select destination folder';
        lTxtFolderPath: Text;
        lTxtFilePath: Text;
        ClientFile: DotNet File;
        InStream: InStream;
        Buffer: Text;
        TextEncoding: DotNet Encoding;
        streamReader: DotNet StreamReader;
        Convert: DotNet Convert;
    begin
        lRecAdiutoSetup.GET;
        IF NOT lRecAdiutoSetup.Enable THEN
            EXIT;

        lRecAdiutoElectrInv.RESET;
        lRecAdiutoElectrInv.SETRANGE(Status, lRecAdiutoSetup."Electr. Doc. Imported Status");
        IF lRecAdiutoElectrInv.FINDSET THEN BEGIN
            lRecAdiutoSetup.TESTFIELD("Electr. Doc. Export Path");
            lTxtFolderPath := lRecAdiutoSetup."Electr. Doc. Export Path";
            IF lTxtFolderPath <> '' THEN BEGIN
                REPEAT
                    lTxtFilePath := lTxtFolderPath + '\' + lRecAdiutoElectrInv."File Name";
                    lRecAdiutoElectrInv.CALCFIELDS("File Content");
                    lRecAdiutoElectrInv."File Content".CREATEINSTREAM(InStream);
                    streamReader := streamReader.StreamReader(InStream, TextEncoding.UTF8, TRUE);
                    Buffer := '';
                    REPEAT
                        Buffer += streamReader.ReadToEnd();
                    UNTIL streamReader.EndOfStream;
                    ClientFile.WriteAllBytes(lTxtFilePath, Convert.FromBase64String(Buffer));
                UNTIL lRecAdiutoElectrInv.NEXT = 0;
            END;
        END;
    end;

    local procedure ElectrInvCreatePCFromVariant(pVariantRec: Variant; pTxtFilePath: Text; pRecAdiutoSetupDetail: Record "Adiuto Setup Detail ED") rBlnOutput: Boolean
    var
        lCduFileManagement: Codeunit "File Management";
        ClientFile: DotNet File;
        lRecAdiutoSetup: Record "Adiuto Setup ED";
        lRefRecord: RecordRef;
    begin
        rBlnOutput := FALSE;
        lRecAdiutoSetup.GET;
        IF NOT lRecAdiutoSetup.Enable THEN
            EXIT;

        lRefRecord.GETTABLE(pVariantRec);
        rBlnOutput := ElectrInvCreatePC(lRefRecord, pTxtFilePath, pRecAdiutoSetupDetail);
    end;

    local procedure ElectrInvCreatePC(pRefRecord: RecordRef; pTxtFilePath: Text; pRecAdiutoSetupDetail: Record "Adiuto Setup Detail ED") rBlnOutput: Boolean
    var
        lCduFileManagement: Codeunit "File Management";
        ClientFile: DotNet File;
        lRecAdiutoSetup: Record "Adiuto Setup ED";
        lRecAdiutoElectrInv: Record "Adiuto Electr. Doc.";
        TextEncoding: DotNet Encoding;
        lOutStream: OutStream;
        streamWriter: DotNet StreamWriter;
        Convert: DotNet Convert;
    begin
        rBlnOutput := FALSE;
        lRecAdiutoSetup.GET;
        IF NOT lRecAdiutoSetup.Enable THEN
            EXIT;

        IF lRecAdiutoElectrInv.GET(pRefRecord.NUMBER, ElectrInvGetRecDocumentNo(pRefRecord), ElectrInvGetRecIdUnivoco(pRefRecord)) THEN BEGIN
            Log(lRecAdiutoElectrInv, 'Create Record FAILED alreafy Found', 'ElectrInvCreatePC');
        END
        ELSE BEGIN
            lRecAdiutoElectrInv.INIT;
            lRecAdiutoElectrInv."Source No." := pRefRecord.NUMBER;
            lRecAdiutoElectrInv."Document No." := ElectrInvGetRecDocumentNo(pRefRecord);
            lRecAdiutoElectrInv.IdUnivoco := ElectrInvGetRecIdUnivoco(pRefRecord);
            lRecAdiutoElectrInv.Barcode := ElectrInvGetRecBarcode(pRefRecord);
            lRecAdiutoElectrInv."Table Id" := pRecAdiutoSetupDetail."Table Id";
            lRecAdiutoElectrInv."File Name" := ElectrInvGetRecFileName(pRefRecord);
            lRecAdiutoElectrInv."File Content".CREATEOUTSTREAM(lOutStream);
            streamWriter := streamWriter.StreamWriter(lOutStream, TextEncoding.UTF8);
            streamWriter.Write(Convert.ToBase64String(ClientFile.ReadAllBytes(pTxtFilePath)));
            streamWriter.Close;
            lRecAdiutoElectrInv.Status := lRecAdiutoSetup."Electr. Doc. Imported Status";
            rBlnOutput := lRecAdiutoElectrInv.INSERT;
            Log(lRecAdiutoElectrInv, 'Create Record', 'ElectrInvCreatePC');
        END;
    end;

    local procedure SalesInvoicesUpdateStatusLoop()
    var
        lRecAdiutoElectrInv: Record "Adiuto Electr. Doc.";
        lRecSalesInvoiceHeader: Record "Sales Invoice Header";
        lRecAdiutoSetup: Record "Adiuto Setup ED";
    begin
        IF NOT lRecAdiutoSetup.GET THEN
            EXIT;


        lRecAdiutoElectrInv.RESET;
        lRecAdiutoElectrInv.SETFILTER(Status, '<>%1', lRecAdiutoSetup."Electr. Doc. Finish Status");
        IF lRecAdiutoElectrInv.FINDSET THEN BEGIN
            REPEAT
                IF lRecAdiutoElectrInv."Source No." = 112 THEN BEGIN
                    IF lRecSalesInvoiceHeader.GET(lRecAdiutoElectrInv."Document No.") THEN
                        AdiutoGetPublishedStatus(lRecSalesInvoiceHeader);
                END;
            UNTIL lRecAdiutoElectrInv.NEXT = 0;
        END;
    end;

    local procedure GetConnectedUser(pRecUser: Record "User"): Text
    var
        lRecAdiutoSetup: Record "Adiuto Setup ED";
        lRecordRef: RecordRef;
        lFieldRef: FieldRef;
    begin
        //>ADI-001
        lRecAdiutoSetup.GET;
        lRecAdiutoSetup.TESTFIELD("Connected User Field No.");
        lRecordRef.GETTABLE(pRecUser);
        lFieldRef := lRecordRef.FIELD(lRecAdiutoSetup."Connected User Field No.");
        lFieldRef.TESTFIELD;
        EXIT(FORMAT(lFieldRef.VALUE));
        //<ADI-001
    end;

    procedure IsErrorStatus(pElectronicDocumentStatus: Code[50]): Boolean
    var
        lRecAdiutoSetupED: Record "Adiuto Setup ED";
    begin
        //>ADI-002
        lRecAdiutoSetupED.GET;
        IF pElectronicDocumentStatus <> '' THEN
            IF pElectronicDocumentStatus <> lRecAdiutoSetupED."Electr. Doc. Publish Status" THEN
                IF pElectronicDocumentStatus <> lRecAdiutoSetupED."Electr. Doc. Delivery Status" THEN
                    EXIT(TRUE);
        EXIT(FALSE);
        //<ADI-002
    end;

    procedure GetBarcode(RecVariant: Variant) rTxtReturn: Text
    var
        lRecAdiutoSetup: Record "Adiuto Setup ED";
        lRecordRef: RecordRef;
        lFieldRef: FieldRef;
    begin
        rTxtReturn := '';
        lRecAdiutoSetup.GET;
        IF lRecAdiutoSetup."Invoice Barcode Field No." <> 0 THEN BEGIN
            lRecordRef.GETTABLE(RecVariant);
            lFieldRef := lRecordRef.FIELD(lRecAdiutoSetup."Invoice Barcode Field No.");
            rTxtReturn := lFieldRef.VALUE;
        END;
    end;

    local procedure ___________EVENTS__________()
    begin
    end;

    [BusinessEvent(false)]
    procedure OnBeforeReportPrint(RecordVariant: Variant; ReportID: Integer; ReportCode: Code[20])
    begin
    end;
}

