codeunit 75003 "Adiuto ED Management"
{
    // version ADI.003

    // JM-FM20190131
    //   bug-fix posting No. after posting process
    // JM-FM20190207
    //   bug-fix document id changed
    // JM-FM20190214
    //   bug-fix set Hide Validation Dialog
    // JM-FM20190219
    //   bug-fix for currency iso code search
    // JM-FM20190408
    //   bug-fix for comments
    // JM-FM20190416
    //   bug-fix for adiuto commit
    // JM-FM20190506
    //   bug-fix for wrong date format


    trigger OnRun()
    var
        lCduAdiutoDocuments: Codeunit "Adiuto Documents ED";
        lRecElectrInvTempHeader: Record "Electr. Doc. Temp. Header";
    begin
        lCduAdiutoDocuments.AdiutoElectrInvoiceDownloadAll(FALSE);
        AdiutoElectrInvoiceImportProcess(FALSE);

        lRecElectrInvTempHeader.RESET;
        lRecElectrInvTempHeader.SETRANGE(lRecElectrInvTempHeader."Reg. Source No.", 0);
        lRecElectrInvTempHeader.SETRANGE(lRecElectrInvTempHeader."Reg. Document No.", '');
        lRecElectrInvTempHeader.SETFILTER(lRecElectrInvTempHeader."Buy-from Vendor No.", '<>''''');
        AdiutoElectrInvoicePreRegisterProcess(lRecElectrInvTempHeader, FALSE);
    end;

    procedure AdiutoElectrInvoiceImportProcess(pBlnShowMessage: Boolean)
    var
        lRecAdiutoSetup: Record "Adiuto Setup ED";
        lRecAdiutoElectrInv: Record "Adiuto Electr. Doc.";
        lCduFileManagement: Codeunit "File Management";
        Text001: Label 'Import of %1 documents from Adiuto';
        lTxtFolderPath: Text;
        lTxtFilePath: Text;
        ClientFile: DotNet File;
        InStream: InStream;
        Buffer: Text;
        TextEncoding: DotNet Encoding;
        streamReader: DotNet StreamReader;
        Convert: DotNet Convert;
        lCduAdiutoNetWebService: Codeunit "Adiuto Net Web Service ED";
        lIntCount: Integer;
        lRecElectrInvTempTable: Record "Electr. Doc. Temp. Header";
        lRecAdiutoSetupDetail: Record "Adiuto Setup Detail ED";
        lIntDocId: Integer;
    begin
        lRecAdiutoSetup.GET;
        IF NOT lRecAdiutoSetup.Enable THEN
            EXIT;

        lRecAdiutoSetup.TESTFIELD("Electr. Doc. Export Path");
        lRecAdiutoSetup.TESTFIELD("Electr. Doc. Pre-Reg. Enable");

        lRecAdiutoElectrInv.RESET;
        lRecAdiutoElectrInv.SETRANGE(Status, lRecAdiutoSetup."Electr. Doc. Imported Status");
        IF lRecAdiutoElectrInv.FINDSET THEN BEGIN
            lRecAdiutoSetup.TESTFIELD("Electr. Doc. Export Path");
            lTxtFolderPath := lRecAdiutoSetup."Electr. Doc. Export Path";
            IF lTxtFolderPath <> '' THEN BEGIN
                lIntCount := 0;
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
                    Buffer := ClientFile.ReadAllText(lTxtFilePath);

                    IF NOT lRecElectrInvTempTable.GET(lRecAdiutoElectrInv."Source No.", lRecAdiutoElectrInv."Document No.", lRecAdiutoElectrInv.IdUnivoco) THEN BEGIN
                        InsertElectrInvTempTable(lRecAdiutoElectrInv, Buffer);
                        IF lRecElectrInvTempTable.GET(lRecAdiutoElectrInv."Source No.", lRecAdiutoElectrInv."Document No.", lRecAdiutoElectrInv.IdUnivoco) THEN BEGIN
                            /*
                              lRecAdiutoSetupDetail.SETRANGE("Primary Key", lRecAdiutoSetup."Primary Key");
                              lRecAdiutoSetupDetail.SETRANGE("Table Id", lRecElectrInvTempTable."Table Id");
                              lRecAdiutoSetupDetail.SETRANGE("Document Type", lRecElectrInvTempTable."Document Type");
                              lRecAdiutoSetupDetail.SETRANGE("XML Invoice", lRecAdiutoSetupDetail."XML Invoice"::"Passive Cycle");
                              IF lRecAdiutoSetupDetail.FINDFIRST THEN BEGIN
                                lRecAdiutoElectrInv.Status := lRecAdiutoSetup."Electr. Inv. Pre-Reg. Status";
                                lRecAdiutoElectrInv.MODIFY;

                                lIntDocId:=0;
                                IF (EVALUATE(lIntDocId, lRecAdiutoElectrInv.IdUnivoco)) THEN BEGIN
                                  lCduAdiutoNetWebService.ElectrInvoiceModifyDoc(lIntDocId, lRecAdiutoSetupDetail, lRecAdiutoElectrInv);
                                END;
                              END;
                              */
                            lIntCount += 1;
                        END;
                    END;
                UNTIL lRecAdiutoElectrInv.NEXT = 0;
                IF (pBlnShowMessage) THEN
                    MESSAGE(STRSUBSTNO(Text001, lIntCount));
            END;
        END;

    end;

    procedure AdiutoElectrInvoicePreRegisterProcess(var pRecElectrInvTempTable: Record "Electr. Doc. Temp. Header"; pBlnShowMessage: Boolean)
    var
        lRecPurchaseHeader: Record "Purchase Header";
        lRecAdiutoElectrInv: Record "Adiuto Electr. Doc.";
        lRecAdiutoSetupDetail: Record "Adiuto Setup Detail ED";
        lRecAdiutoSetup: Record "Adiuto Setup ED";
        lCduAdiutoNetWebService: Codeunit "Adiuto Net Web Service ED";
        lIntDocId: Integer;
        RefRecordPurchHeader: RecordRef;
        lTxtResult: Text;
    begin
        lRecAdiutoSetup.GET;
        IF NOT lRecAdiutoSetup.Enable THEN
            EXIT;
        IF NOT lRecAdiutoSetup."Electr. Doc. Pre-Reg. Enable" THEN
            EXIT;

        CreatePurchaseHeader(pRecElectrInvTempTable);
        COMMIT;
        IF lRecPurchaseHeader.GET(pRecElectrInvTempTable."Document Type", pRecElectrInvTempTable."Reg. Document No.") THEN BEGIN
            IF (pBlnShowMessage) THEN BEGIN
                IF lRecPurchaseHeader."Document Type" = lRecPurchaseHeader."Document Type"::Invoice THEN BEGIN
                    IF NOT (PAGE.RUNMODAL(PAGE::"Purchase Invoices", lRecPurchaseHeader) = ACTION::LookupOK) THEN
                        EXIT;
                END
                ELSE
                    IF lRecPurchaseHeader."Document Type" = lRecPurchaseHeader."Document Type"::"Credit Memo" THEN BEGIN
                        IF NOT (PAGE.RUNMODAL(PAGE::"Purchase Credit Memos", lRecPurchaseHeader) = ACTION::LookupOK) THEN
                            EXIT;
                    END;
            END;
            IF pRecElectrInvTempTable.FINDSET THEN BEGIN
                REPEAT
                    IF lRecAdiutoElectrInv.GET(pRecElectrInvTempTable."Source No.", pRecElectrInvTempTable."Document No.", pRecElectrInvTempTable.IdUnivoco) THEN BEGIN
                        lRecAdiutoSetupDetail.SETRANGE("Primary Key", lRecAdiutoSetup."Primary Key");
                        lRecAdiutoSetupDetail.SETRANGE("Table Id", lRecAdiutoElectrInv."Table Id");
                        lRecAdiutoSetupDetail.SETRANGE("XML Document", lRecAdiutoSetupDetail."XML Document"::"Passive XML");
                        IF lRecAdiutoSetupDetail.FINDFIRST THEN BEGIN
                            lRecAdiutoElectrInv.Status := lRecAdiutoSetup."Electr. Doc. Pre-Reg. Status";
                            lRecAdiutoElectrInv.MODIFY;

                            lIntDocId := 0;
                            //>JM-FM20190207
                            //IF (EVALUATE(lIntDocId, lRecAdiutoElectrInv.IdUnivoco)) THEN
                            RefRecordPurchHeader.GETTABLE(lRecPurchaseHeader);
                            lTxtResult := lCduAdiutoNetWebService.GetDocId(lRecAdiutoSetupDetail, RefRecordPurchHeader);
                            IF EVALUATE(lIntDocId, lTxtResult) THEN
                                //<JM-FM20190207
                                lCduAdiutoNetWebService.ElectrInvoiceModifyDoc(lIntDocId, lRecAdiutoSetupDetail, lRecAdiutoElectrInv);
                            //>JM-FM20190207
                            COMMIT;
                            //<JM-FM20190207
                        END;
                    END;
                UNTIL pRecElectrInvTempTable.NEXT = 0;
            END;
        END;
    end;

    [EventSubscriber(ObjectType::Codeunit, 90, 'OnAfterPostPurchaseDoc', '', true, true)]
    local procedure AdiutoElectrInvoiceAfterRegProcess(var PurchaseHeader: Record "Purchase Header"; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; PurchRcpHdrNo: Code[20]; RetShptHdrNo: Code[20]; PurchInvHdrNo: Code[20]; PurchCrMemoHdrNo: Code[20])
    var
        lRecElectrInvTempHeader: Record "Electr. Doc. Temp. Header";
        lRecAdiutoSetupDetail: Record "Adiuto Setup Detail ED";
        lRecAdiutoSetup: Record "Adiuto Setup ED";
        lRecAdiutoElectrInv: Record "Adiuto Electr. Doc.";
        lIntDocId: Integer;
        lCduAdiutoNetWebService: Codeunit "Adiuto Net Web Service ED";
        RefRecord: RecordRef;
        lRecPurchInvHeader: Record "Purch. Inv. Header";
        lRecPurchCrMemoHdr: Record "Purch. Cr. Memo Hdr.";
        lRecAdiutoSetupDetailPosting: Record "Adiuto Setup Detail ED";
        RefRecordPurchHeader: RecordRef;
        lTxtResult: Text;
        lCduAdiutoDocuments: Codeunit "Adiuto Documents ED";
        lTxtBarcode: Text;
        lIntSource: Integer;
    begin
        IF NOT lRecAdiutoSetup.GET THEN
            EXIT;

        IF NOT lRecAdiutoSetup.Enable THEN
            EXIT;

        lRecElectrInvTempHeader.RESET;
        lRecElectrInvTempHeader.SETRANGE(lRecElectrInvTempHeader."Reg. Document No.", PurchaseHeader."No.");
        lRecElectrInvTempHeader.SETRANGE(lRecElectrInvTempHeader."Reg. Document Type", PurchaseHeader."Document Type");
        lRecElectrInvTempHeader.SETRANGE(lRecElectrInvTempHeader."Reg. Source No.", DATABASE::"Purchase Header");
        IF lRecElectrInvTempHeader.FINDFIRST THEN BEGIN
            lRecAdiutoElectrInv.RESET;
            lRecAdiutoElectrInv.SETRANGE(Barcode, lRecElectrInvTempHeader.Barcode);
            IF NOT lRecAdiutoElectrInv.FINDFIRST THEN
                EXIT;
            lRecAdiutoSetupDetail.SETRANGE("Primary Key", lRecAdiutoSetup."Primary Key");
            lRecAdiutoSetupDetail.SETRANGE("Table Id", lRecAdiutoElectrInv."Table Id");
            lRecAdiutoSetupDetail.SETRANGE("XML Document", lRecAdiutoSetupDetail."XML Document"::"Passive XML");
            IF lRecAdiutoSetupDetail.FINDFIRST THEN BEGIN
                lRecAdiutoElectrInv.Status := lRecAdiutoSetup."Electr. Doc. Registered Status";
                lRecAdiutoElectrInv.MODIFY;

                lIntDocId := 0;
                /*
                    //>JM-FM20190207
                //    IF (EVALUATE(lIntDocId, lRecAdiutoElectrInv.IdUnivoco)) THEN BEGIN
                    RefRecordPurchHeader.GETTABLE(PurchaseHeader);
                    lTxtResult := lCduAdiutoNetWebService.GetDocId(lRecAdiutoSetupDetail, RefRecordPurchHeader);
                    IF EVALUATE(lIntDocId, lTxtResult) THEN BEGIN
                    //<JM-FM20190207
                      lCduAdiutoNetWebService.ElectrInvoiceModifyDoc(lIntDocId, lRecAdiutoSetupDetail, lRecAdiutoElectrInv);
                      //>JM-FM20190131
                */
                IF lRecPurchInvHeader.GET(PurchInvHdrNo) THEN BEGIN
                    RefRecord.GETTABLE(lRecPurchInvHeader);
                    lRecAdiutoSetupDetailPosting.RESET;
                    lRecAdiutoSetupDetailPosting.SETRANGE(lRecAdiutoSetupDetailPosting."Primary Key", lRecAdiutoSetup."Primary Key");
                    lRecAdiutoSetupDetailPosting.SETRANGE(lRecAdiutoSetupDetailPosting."Table Id", DATABASE::"Purch. Inv. Header");
                    lRecAdiutoSetupDetailPosting.SETRANGE(lRecAdiutoSetupDetailPosting."XML Document", lRecAdiutoSetupDetailPosting."XML Document"::" ");
                    IF lRecAdiutoSetupDetailPosting.FINDFIRST THEN BEGIN
                        lIntDocId := 0;
                        lTxtResult := lCduAdiutoNetWebService.GetDocId(lRecAdiutoSetupDetailPosting, RefRecord);
                        IF EVALUATE(lIntDocId, lTxtResult) THEN BEGIN
                            lCduAdiutoNetWebService.ElectrInvoiceModifyDoc(lIntDocId, lRecAdiutoSetupDetail, lRecAdiutoElectrInv);
                            lCduAdiutoNetWebService.ModifyDocument(lIntDocId, lRecAdiutoSetupDetailPosting, RefRecord);
                        END;
                    END;
                END;
                IF lRecPurchCrMemoHdr.GET(PurchCrMemoHdrNo) THEN BEGIN
                    RefRecord.GETTABLE(lRecPurchCrMemoHdr);
                    lRecAdiutoSetupDetailPosting.RESET;
                    lRecAdiutoSetupDetailPosting.SETRANGE(lRecAdiutoSetupDetailPosting."Primary Key", lRecAdiutoSetup."Primary Key");
                    lRecAdiutoSetupDetailPosting.SETRANGE(lRecAdiutoSetupDetailPosting."Table Id", DATABASE::"Purch. Cr. Memo Hdr.");
                    lRecAdiutoSetupDetailPosting.SETRANGE(lRecAdiutoSetupDetailPosting."XML Document", lRecAdiutoSetupDetailPosting."XML Document"::" ");
                    IF lRecAdiutoSetupDetailPosting.FINDFIRST THEN BEGIN
                        lIntDocId := 0;
                        lTxtResult := lCduAdiutoNetWebService.GetDocId(lRecAdiutoSetupDetailPosting, RefRecord);
                        IF EVALUATE(lIntDocId, lTxtResult) THEN BEGIN
                            lCduAdiutoNetWebService.ElectrInvoiceModifyDoc(lIntDocId, lRecAdiutoSetupDetail, lRecAdiutoElectrInv);
                            lCduAdiutoNetWebService.ModifyDocument(lIntDocId, lRecAdiutoSetupDetailPosting, RefRecord);
                        END;
                    END;
                END;
                //<JM-FM20190131
            END;
            //  END;
            //<JM-FM20190417
        END ELSE BEGIN
            lRecAdiutoSetupDetail.RESET;
            lRecAdiutoSetupDetail.SETRANGE(lRecAdiutoSetupDetail."Primary Key", lRecAdiutoSetup."Primary Key");
            lRecAdiutoSetupDetail.SETRANGE(lRecAdiutoSetupDetail."XML Document", lRecAdiutoSetupDetail."XML Document"::"Passive XML");
            IF NOT lRecAdiutoSetupDetail.FINDFIRST THEN
                EXIT;
            lIntSource := DATABASE::"Purch. Inv. Header";
            IF (PurchaseHeader."Document Type" = PurchaseHeader."Document Type"::"Credit Memo") THEN
                lIntSource := DATABASE::"Purch. Cr. Memo Hdr.";
            lTxtBarcode := lCduAdiutoDocuments.GetBarcode(PurchaseHeader);

            lRecAdiutoElectrInv.RESET;
            lRecAdiutoElectrInv.SETRANGE(lRecAdiutoElectrInv.Barcode, lTxtBarcode);
            IF NOT lRecAdiutoElectrInv.FINDFIRST THEN BEGIN
                lRecAdiutoElectrInv.INIT;
                lRecAdiutoElectrInv."Source No." := lIntSource;
                lRecAdiutoElectrInv."Document No." := COPYSTR(PurchInvHdrNo + PurchCrMemoHdrNo, 1, 20);
                lRecAdiutoElectrInv.IdUnivoco := '';
                lRecAdiutoElectrInv.Status := lRecAdiutoSetup."Electr. Doc. Registered Status";
                lRecAdiutoElectrInv.Barcode := lTxtBarcode;
                lRecAdiutoElectrInv."Table Id" := lIntSource;
                lRecAdiutoElectrInv.INSERT;
            END;

            lRecAdiutoElectrInv.Status := lRecAdiutoSetup."Electr. Doc. Registered Status";
            lRecAdiutoElectrInv.MODIFY(FALSE);

            /*
              lIntDocId:=0;
              RefRecordPurchHeader.GETTABLE(PurchaseHeader);
              lTxtResult := lCduAdiutoNetWebService.GetDocId(lRecAdiutoSetupDetail, RefRecordPurchHeader);
              IF EVALUATE(lIntDocId, lTxtResult) THEN BEGIN
                lCduAdiutoNetWebService.ElectrInvoiceModifyDoc(lIntDocId, lRecAdiutoSetupDetail, lRecAdiutoElectrInv);
            */
            IF lRecPurchInvHeader.GET(PurchInvHdrNo) THEN BEGIN
                RefRecord.GETTABLE(lRecPurchInvHeader);
                lRecAdiutoSetupDetailPosting.RESET;
                lRecAdiutoSetupDetailPosting.SETRANGE(lRecAdiutoSetupDetailPosting."Primary Key", lRecAdiutoSetup."Primary Key");
                lRecAdiutoSetupDetailPosting.SETRANGE(lRecAdiutoSetupDetailPosting."Table Id", DATABASE::"Purch. Inv. Header");
                lRecAdiutoSetupDetailPosting.SETRANGE(lRecAdiutoSetupDetailPosting."XML Document", lRecAdiutoSetupDetailPosting."XML Document"::" ");
                IF lRecAdiutoSetupDetailPosting.FINDFIRST THEN BEGIN
                    lIntDocId := 0;
                    lTxtResult := lCduAdiutoNetWebService.GetDocId(lRecAdiutoSetupDetailPosting, RefRecord);
                    IF EVALUATE(lIntDocId, lTxtResult) THEN BEGIN
                        lCduAdiutoNetWebService.ElectrInvoiceModifyDoc(lIntDocId, lRecAdiutoSetupDetail, lRecAdiutoElectrInv);
                        lCduAdiutoNetWebService.ModifyDocument(lIntDocId, lRecAdiutoSetupDetailPosting, RefRecord);
                    END;
                END;
            END;
            IF lRecPurchCrMemoHdr.GET(PurchCrMemoHdrNo) THEN BEGIN
                RefRecord.GETTABLE(lRecPurchCrMemoHdr);
                lRecAdiutoSetupDetailPosting.RESET;
                lRecAdiutoSetupDetailPosting.SETRANGE(lRecAdiutoSetupDetailPosting."Primary Key", lRecAdiutoSetup."Primary Key");
                lRecAdiutoSetupDetailPosting.SETRANGE(lRecAdiutoSetupDetailPosting."Table Id", DATABASE::"Purch. Cr. Memo Hdr.");
                lRecAdiutoSetupDetailPosting.SETRANGE(lRecAdiutoSetupDetailPosting."XML Document", lRecAdiutoSetupDetailPosting."XML Document"::" ");
                IF lRecAdiutoSetupDetailPosting.FINDFIRST THEN BEGIN
                    lIntDocId := 0;
                    lTxtResult := lCduAdiutoNetWebService.GetDocId(lRecAdiutoSetupDetailPosting, RefRecord);
                    IF EVALUATE(lIntDocId, lTxtResult) THEN BEGIN
                        lCduAdiutoNetWebService.ElectrInvoiceModifyDoc(lIntDocId, lRecAdiutoSetupDetail, lRecAdiutoElectrInv);
                        lCduAdiutoNetWebService.ModifyDocument(lIntDocId, lRecAdiutoSetupDetailPosting, RefRecord);
                    END;
                END;
            END;
            //  END;

            lRecElectrInvTempHeader.RESET;
            lRecElectrInvTempHeader.SETRANGE(lRecElectrInvTempHeader."Barcode", lTxtBarcode);
            lRecElectrInvTempHeader.SETRANGE(lRecElectrInvTempHeader."Source No.", DATABASE::"Adiuto Electr. Doc.");
            IF lRecElectrInvTempHeader.FINDFIRST THEN BEGIN
                lRecElectrInvTempHeader."Reg. Document Type" := PurchaseHeader."Document Type";
                lRecElectrInvTempHeader."Reg. Document No." := PurchaseHeader."No.";
                lRecElectrInvTempHeader."Reg. Source No." := DATABASE::"Purchase Header";
                lRecElectrInvTempHeader.MODIFY(FALSE);
            END;
            //<JM-FM20190417
        END;

    end;

    local procedure InsertElectrInvTempTable(var lRecAdiutoElectrInv: Record "Adiuto Electr. Doc."; pTxtFileContent: Text) rBlnValue: Boolean
    var
        lTxtContent: BigText;
        lTxtXML: Text;
        lTxtEnvelopeXML: Text;
        lIntPosition: Integer;
        lTxtXmlHeaderTag: Text;
        lRecElectrInvTempTable: Record "Electr. Doc. Temp. Header";
        lTxtXmlCommentStartTag: Text;
        lIntPositionEnd: Integer;
        lTxtXmlCommentEndTag: Text;
        lIntPositionStart: Integer;
    begin
        rBlnValue := FALSE;
        IF lRecElectrInvTempTable.GET(lRecAdiutoElectrInv."Source No.", lRecAdiutoElectrInv."Document No.", lRecAdiutoElectrInv.IdUnivoco) THEN
            EXIT;

        lRecElectrInvTempTable.INIT;
        lRecElectrInvTempTable."Source No." := lRecAdiutoElectrInv."Source No.";
        lRecElectrInvTempTable."Document No." := lRecAdiutoElectrInv."Document No.";
        lRecElectrInvTempTable.IdUnivoco := lRecAdiutoElectrInv.IdUnivoco;
        lRecElectrInvTempTable.Barcode := lRecAdiutoElectrInv.Barcode;
        lRecElectrInvTempTable.INSERT;

        //Normalizzazione XML
        lTxtEnvelopeXML := pTxtFileContent;
        lTxtXmlHeaderTag := '?>';
        REPEAT
            //Controllo Header
            lIntPosition := STRPOS(lTxtEnvelopeXML, lTxtXmlHeaderTag);
            IF lIntPosition > 0 THEN
                lTxtEnvelopeXML := COPYSTR(lTxtEnvelopeXML, lIntPosition + STRLEN(lTxtXmlHeaderTag));
            lTxtEnvelopeXML := DELCHR(lTxtEnvelopeXML, '<>', ' ');
        UNTIL lIntPosition <= 0;

        lTxtEnvelopeXML := DELCHR(lTxtEnvelopeXML, '<>', ' ');

        //>COMMENT-FIX
        lTxtXmlCommentStartTag := 'FatturaElettronica';
        lTxtXmlCommentEndTag := '-->';
        lIntPosition := STRPOS(UPPERCASE(lTxtEnvelopeXML), UPPERCASE(lTxtXmlCommentStartTag));
        lIntPositionEnd := STRPOS(lTxtEnvelopeXML, lTxtXmlCommentEndTag);
        IF lIntPositionEnd < lIntPosition THEN BEGIN
            REPEAT
                //Controllo commenti
                lIntPosition := STRPOS(UPPERCASE(lTxtEnvelopeXML), UPPERCASE(lTxtXmlCommentStartTag));
                lIntPositionEnd := STRPOS(lTxtEnvelopeXML, lTxtXmlCommentEndTag);
                IF (lIntPosition > lIntPositionEnd) AND (lIntPositionEnd > 0) THEN //Se il commento è in testa lo elimino
                    lTxtEnvelopeXML := COPYSTR(lTxtEnvelopeXML, lIntPositionEnd + STRLEN(lTxtXmlCommentEndTag));
                lTxtEnvelopeXML := DELCHR(lTxtEnvelopeXML, '<>', ' ');
            UNTIL ((lIntPosition <= lIntPositionEnd) OR (lIntPositionEnd = 0));
        END;
        //<COMMENT-FIX

        lTxtEnvelopeXML := DELCHR(lTxtEnvelopeXML, '<>', ' ');

        lIntPosition := STRPOS(lTxtEnvelopeXML, '<');
        lTxtEnvelopeXML := COPYSTR(lTxtEnvelopeXML, lIntPosition);


        GetXmlTagValue(lRecElectrInvTempTable."XML_1.1.1.1 IdPaese",
          'p:FatturaElettronica/FatturaElettronicaHeader/DatiTrasmissione/IdTrasmittente/IdPaese', lTxtEnvelopeXML);
        GetXmlTagValue(lRecElectrInvTempTable."XML_1.1.1.2 IdCodice",
          'p:FatturaElettronica/FatturaElettronicaHeader/DatiTrasmissione/IdTrasmittente/IdCodice', lTxtEnvelopeXML);
        GetXmlTagValue(lRecElectrInvTempTable."XML_1.1.2 Progr. Invio",
          'p:FatturaElettronica/FatturaElettronicaHeader/DatiTrasmissione/ProgressivoInvio', lTxtEnvelopeXML);
        GetXmlTagValue(lRecElectrInvTempTable."XML_1.1.3 FormatoTrasmissione",
          'p:FatturaElettronica/FatturaElettronicaHeader/DatiTrasmissione/FormatoTrasmissione', lTxtEnvelopeXML);
        GetXmlTagValue(lRecElectrInvTempTable."XML_1.1.4 CodiceDestinatario",
          'p:FatturaElettronica/FatturaElettronicaHeader/DatiTrasmissione/CodiceDestinatario', lTxtEnvelopeXML);
        GetXmlTagValue(lRecElectrInvTempTable."XML_1.1.6 PECDestinatario",
          'p:FatturaElettronica/FatturaElettronicaHeader/DatiTrasmissione/PECDestinatario', lTxtEnvelopeXML);

        GetXmlTagValue(lRecElectrInvTempTable."XML_1.2.1.1.1 IdPaese",
          'p:FatturaElettronica/FatturaElettronicaHeader/CedentePrestatore/DatiAnagrafici/IdFiscaleIVA/IdPaese', lTxtEnvelopeXML);
        GetXmlTagValue(lRecElectrInvTempTable."XML_1.2.1.1.2 IdCodice",
          'p:FatturaElettronica/FatturaElettronicaHeader/CedentePrestatore/DatiAnagrafici/IdFiscaleIVA/IdCodice', lTxtEnvelopeXML);
        GetXmlTagValue(lRecElectrInvTempTable."XML_1.2.1.2 CodiceFiscale",
          'p:FatturaElettronica/FatturaElettronicaHeader/CedentePrestatore/DatiAnagrafici/CodiceFiscale', lTxtEnvelopeXML);
        GetXmlTagValue(lRecElectrInvTempTable."XML_1.2.1.3.1 Denominazione",
          'p:FatturaElettronica/FatturaElettronicaHeader/CedentePrestatore/DatiAnagrafici/Anagrafica/Denominazione', lTxtEnvelopeXML);
        GetXmlTagValue(lRecElectrInvTempTable."XML_1.2.1.3.2 Nome",
          'p:FatturaElettronica/FatturaElettronicaHeader/CedentePrestatore/DatiAnagrafici/Anagrafica/Nome', lTxtEnvelopeXML);
        GetXmlTagValue(lRecElectrInvTempTable."XML_1.2.1.3.3 Cognome",
          'p:FatturaElettronica/FatturaElettronicaHeader/CedentePrestatore/DatiAnagrafici/Anagrafica/Cognome', lTxtEnvelopeXML);
        GetXmlTagValue(lRecElectrInvTempTable."XML_1.2.1.3.4 Titolo",
          'p:FatturaElettronica/FatturaElettronicaHeader/CedentePrestatore/DatiAnagrafici/Anagrafica/Titolo', lTxtEnvelopeXML);
        GetXmlTagValue(lRecElectrInvTempTable."XML_1.2.1.3.5 CodEORI",
          'p:FatturaElettronica/FatturaElettronicaHeader/CedentePrestatore/DatiAnagrafici/Anagrafica/CodEORI', lTxtEnvelopeXML);

        GetXmlTagValue(lRecElectrInvTempTable."XML_1.2.2.1 Indirizzo",
          'p:FatturaElettronica/FatturaElettronicaHeader/CedentePrestatore/Sede/Indirizzo', lTxtEnvelopeXML);
        GetXmlTagValue(lRecElectrInvTempTable."XML_1.2.2.2 NumeroCivico",
          'p:FatturaElettronica/FatturaElettronicaHeader/CedentePrestatore/Sede/NumeroCivico', lTxtEnvelopeXML);
        GetXmlTagValue(lRecElectrInvTempTable."XML_1.2.2.3 CAP",
          'p:FatturaElettronica/FatturaElettronicaHeader/CedentePrestatore/Sede/CAP', lTxtEnvelopeXML);
        GetXmlTagValue(lRecElectrInvTempTable."XML_1.2.2.4 Comune",
          'p:FatturaElettronica/FatturaElettronicaHeader/CedentePrestatore/Sede/Comune', lTxtEnvelopeXML);
        GetXmlTagValue(lRecElectrInvTempTable."XML_1.2.2.5 Provincia",
          'p:FatturaElettronica/FatturaElettronicaHeader/CedentePrestatore/Sede/Provincia', lTxtEnvelopeXML);
        GetXmlTagValue(lRecElectrInvTempTable."XML_1.2.2.6 Nazione",
          'p:FatturaElettronica/FatturaElettronicaHeader/CedentePrestatore/Sede/Nazione', lTxtEnvelopeXML);

        GetXmlTagValue(lRecElectrInvTempTable."XML_2.1.1.1 TipoDocumento",
          'p:FatturaElettronica/FatturaElettronicaBody/DatiGenerali/DatiGeneraliDocumento/TipoDocumento', lTxtEnvelopeXML);
        GetXmlTagValue(lRecElectrInvTempTable."XML_2.1.1.2 Divisa",
          'p:FatturaElettronica/FatturaElettronicaBody/DatiGenerali/DatiGeneraliDocumento/Divisa', lTxtEnvelopeXML);
        //>JM-FM20190514
        //GetXmlTagValue(lRecElectrInvTempTable."XML_2.1.1.3 Data",
        //  'p:FatturaElettronica/FatturaElettronicaBody/DatiGenerali/DatiGeneraliDocumento/Data', lTxtEnvelopeXML);
        GetXmlTagValueWithLength(lRecElectrInvTempTable."XML_2.1.1.3 Data",
          'p:FatturaElettronica/FatturaElettronicaBody/DatiGenerali/DatiGeneraliDocumento/Data', lTxtEnvelopeXML, 10, TRUE);
        //<JM-FM20190514
        GetXmlTagValue(lRecElectrInvTempTable."XML_2.1.1.4 Numero",
          'p:FatturaElettronica/FatturaElettronicaBody/DatiGenerali/DatiGeneraliDocumento/Numero', lTxtEnvelopeXML);
        GetXmlTagValue(lRecElectrInvTempTable."XML_2.1.1.5.1 TipoRitenuta",
          'p:FatturaElettronica/FatturaElettronicaBody/DatiGenerali/DatiGeneraliDocumento/DatiRitenuta/TipoRitenuta', lTxtEnvelopeXML);
        GetXmlTagValue(lRecElectrInvTempTable."XML_2.1.1.5.2 ImportoRitenuta",
          'p:FatturaElettronica/FatturaElettronicaBody/DatiGenerali/DatiGeneraliDocumento/DatiRitenuta/ImportoRitenuta', lTxtEnvelopeXML);
        GetXmlTagValue(lRecElectrInvTempTable."XML_2.1.1.5.3 AliquotaRitenuta",
          'p:FatturaElettronica/FatturaElettronicaBody/DatiGenerali/DatiGeneraliDocumento/DatiRitenuta/AliquotaRitenuta', lTxtEnvelopeXML);
        GetXmlTagValue(lRecElectrInvTempTable."XML_2.1.1.5.4 CausalePagamento",
          'p:FatturaElettronica/FatturaElettronicaBody/DatiGenerali/DatiGeneraliDocumento/DatiRitenuta/CausalePagamento', lTxtEnvelopeXML);
        GetXmlTagValue(lRecElectrInvTempTable."XML_2.1.1.6.1 BolloVirtuale",
          'p:FatturaElettronica/FatturaElettronicaBody/DatiGenerali/DatiGeneraliDocumento/DatiBollo/BolloVirtuale', lTxtEnvelopeXML);
        GetXmlTagValue(lRecElectrInvTempTable."XML_2.1.1.6.2 ImportoBollo",
          'p:FatturaElettronica/FatturaElettronicaBody/DatiGenerali/DatiGeneraliDocumento/DatiBollo/ImportoBollo', lTxtEnvelopeXML);
        GetXmlTagValue(lRecElectrInvTempTable."XML_2.1.1.9 Imp. Tot. Doc.",
          'p:FatturaElettronica/FatturaElettronicaBody/DatiGenerali/DatiGeneraliDocumento/ImportoTotaleDocumento', lTxtEnvelopeXML);
        GetXmlTagValue(lRecElectrInvTempTable."XML_2.1.1.10 Arrotondamento",
          'p:FatturaElettronica/FatturaElettronicaBody/DatiGenerali/DatiGeneraliDocumento/Arrotondamento', lTxtEnvelopeXML);

        GetXmlTagValue(lRecElectrInvTempTable."XML_2.1.2.6 CodiceCIG",
          'p:FatturaElettronica/FatturaElettronicaBody/DatiGenerali/DatiOrdineAcquisto/CodiceCUP', lTxtEnvelopeXML);
        GetXmlTagValue(lRecElectrInvTempTable."XML_2.1.2.7 CodiceCUP",
          'p:FatturaElettronica/FatturaElettronicaBody/DatiGenerali/DatiOrdineAcquisto/CodiceCIG', lTxtEnvelopeXML);

        //>AB20190315
        GetXmlTagValue(lRecElectrInvTempTable."XML_2.4.1 CondizioniPagamento",
          'p:FatturaElettronica/FatturaElettronicaBody/DatiPagamento/CondizioniPagamento', lTxtEnvelopeXML);
        GetXmlTagValue(lRecElectrInvTempTable."XML_2.4.2.2 ModalitaPagamento",
          'p:FatturaElettronica/FatturaElettronicaBody/DatiPagamento/DettaglioPagamento/ModalitaPagamento', lTxtEnvelopeXML);
        //>JM-FM20190506
        //GetXmlTagValue(lRecElectrInvTempTable."XML_2.4.2.5 DataScadPagamento",
        //  'p:FatturaElettronica/FatturaElettronicaBody/DatiPagamento/DettaglioPagamento/DataScadenzaPagamento', lTxtEnvelopeXML);
        GetXmlTagValueWithLength(lRecElectrInvTempTable."XML_2.4.2.5 DataScadPagamento",
          'p:FatturaElettronica/FatturaElettronicaBody/DatiPagamento/DettaglioPagamento/DataScadenzaPagamento', lTxtEnvelopeXML, 10, TRUE);
        //<JM-FM20190506
        //<AB20190315

        lRecElectrInvTempTable.MODIFY;

        ElectrTempTableUpdateFields(lRecElectrInvTempTable);
        rBlnValue := TRUE;
    end;

    procedure SetVendorData(pCodVendorNo: Code[20]; var pRecElectrInvTempTable: Record "Electr. Doc. Temp. Header")
    var
        lRecVendor: Record Vendor;
    begin
        IF pCodVendorNo <> '' THEN BEGIN
            IF lRecVendor.GET(pCodVendorNo) THEN BEGIN
                pRecElectrInvTempTable."Buy-from Vendor Name" := lRecVendor.Name;
                pRecElectrInvTempTable."Buy-from Vendor Name 2" := lRecVendor."Name 2";
                pRecElectrInvTempTable."Buy-from Address" := lRecVendor.Address;
                pRecElectrInvTempTable."Buy-from Address 2" := lRecVendor."Address 2";
                pRecElectrInvTempTable."Buy-from City" := lRecVendor.City;
                pRecElectrInvTempTable."Buy-from Post Code" := lRecVendor."Post Code";
                pRecElectrInvTempTable."Buy-from County" := lRecVendor.County;
                pRecElectrInvTempTable."Buy-from Country/Region Code" := lRecVendor."Country/Region Code";
                pRecElectrInvTempTable."Buy-from Contact" := lRecVendor.Contact;
            END;
        END;
    end;

    [TryFunction]
    local procedure GetXmlTagValue(var pTxtResult: Text; pTxtTag: Text; pTxtXml: Text)
    var
        lTxtXML: Text;
        lIntIndex: Integer;
        lIntLastTag: Integer;
        lDntString: DotNet String;
        lDntArray: DotNet Array;
        lDntSeparator: DotNet String;
        XmlDocument: DotNet XmlDocument;
        XmlNode: DotNet XmlNode;
    begin
        pTxtResult := '';
        lTxtXML := pTxtXml;
        IF lTxtXML = '' THEN
            EXIT;

        LoadXMLDocumentFromText(lTxtXML, XmlDocument);
        XmlNode := XmlDocument.FirstChild;


        lDntString := (pTxtTag);
        lDntSeparator := '/';
        lDntArray := lDntString.Split(lDntSeparator.ToCharArray());
        lIntLastTag := lDntArray.Length() - 1;
        FOR lIntIndex := 0 TO lIntLastTag DO BEGIN
            GetXmlTagNode(lDntArray.GetValue(lIntIndex), XmlNode);
            IF ISNULL(XmlNode) THEN
                EXIT;
            IF lIntIndex = lIntLastTag THEN
                pTxtResult := XmlNode.InnerText;
        END;
    end;

    [TryFunction]
    local procedure GetXmlTagNode(pTxtTag: Text; var XmlNode: DotNet XmlNode)
    var
        lIntChildId: Integer;
        lTxtXML: Text;
        XmlNodeList: DotNet XmlNodeList;
        XmlAttributes: DotNet XmlAttributeCollection;
        XmlDocument: DotNet XmlDocument;
        XmlNSM: DotNet XmlNamespaceManager;
        XmlNameTable: DotNet XmlNameTable;
        out: OutStream;
        MyFile: File;
        blnLoop: Boolean;
        XmlDocumentChild: DotNet XmlDocument;
        lIntIndexChild: Integer;
        lIntIndex: Integer;
        XmlNodeChildList: DotNet XmlNodeList;
        lIntIndexChildFields: Integer;
        XmlNodeChildField: DotNet XmlNode;
        lIntId: Integer;
        lTxtNameGetField: Text;
        lBlnLoop: Boolean;
    begin
        IF pTxtTag <> '' THEN BEGIN
            lBlnLoop := TRUE;
            lIntChildId := 0;
            IF NOT ISNULL(XmlNode) THEN
                XmlNodeChildList := XmlNode.ChildNodes;
            IF ISNULL(XmlNodeChildList) THEN
                //UPDATE                XmlNode.FirstChild;
                XmlNode := XmlNode.FirstChild;
            REPEAT
                IF NOT ISNULL(XmlNode) THEN BEGIN
                    IF RemoveNamespace(UPPERCASE(XmlNode.Name)) = RemoveNamespace(UPPERCASE(pTxtTag)) THEN BEGIN
                        lBlnLoop := FALSE;
                        EXIT;
                    END;
                    XmlNode := XmlNodeChildList.Item(lIntChildId);
                    lIntChildId += 1;
                    //XmlNode := XmlNode.FirstChild;
                END
                ELSE BEGIN
                    lBlnLoop := FALSE;
                END;
            UNTIL lBlnLoop = FALSE;
        END;
    end;

    local procedure ElectrTempTableUpdateFields(var pRecElectrInvTempTable: Record "Electr. Doc. Temp. Header")
    var
        lRecVendor: Record Vendor;
        lRecAdiutoSetup: Record "Adiuto Setup ED";
    begin
        lRecAdiutoSetup.GET;

        pRecElectrInvTempTable."Document Type" := GetDocumentType(pRecElectrInvTempTable."XML_2.1.1.1 TipoDocumento");
        pRecElectrInvTempTable."Document Date" := GetDateValue(pRecElectrInvTempTable."XML_2.1.1.3 Data");
        //>JM-FM20190416
        //pRecElectrInvTempTable."Posting Date"   := WORKDATE;
        pRecElectrInvTempTable."Posting Date" := 0D;
        IF lRecAdiutoSetup."El. Doc. Posting Date" = lRecAdiutoSetup."El. Doc. Posting Date"::Workdate THEN
            pRecElectrInvTempTable."Posting Date" := WORKDATE
        ELSE
            IF lRecAdiutoSetup."El. Doc. Posting Date" = lRecAdiutoSetup."El. Doc. Posting Date"::"Document date" THEN
                pRecElectrInvTempTable."Posting Date" := pRecElectrInvTempTable."Document Date"
            ELSE
                IF lRecAdiutoSetup."El. Doc. Posting Date" = lRecAdiutoSetup."El. Doc. Posting Date"::"End Month Document date" THEN
                    pRecElectrInvTempTable."Posting Date" := CALCDATE('CM', pRecElectrInvTempTable."Document Date");
        //>JM-FM20190416

        IF pRecElectrInvTempTable."XML_2.1.1.2 Divisa" <> lRecAdiutoSetup."Electr. Doc. Currency Code" THEN
            pRecElectrInvTempTable."Currency Code" := pRecElectrInvTempTable."XML_2.1.1.2 Divisa";

        pRecElectrInvTempTable."Table Id" := DATABASE::"Purchase Header";

        IF pRecElectrInvTempTable."Document Type" = pRecElectrInvTempTable."Document Type"::Invoice THEN BEGIN
            pRecElectrInvTempTable."Vendor Invoice No." := pRecElectrInvTempTable."XML_2.1.1.4 Numero";
        END
        ELSE
            IF pRecElectrInvTempTable."Document Type" = pRecElectrInvTempTable."Document Type"::"Credit Memo" THEN BEGIN
                pRecElectrInvTempTable."Vendor Cr. Memo No." := pRecElectrInvTempTable."XML_2.1.1.4 Numero";
            END;
        pRecElectrInvTempTable."Check Total" :=
          GetDecimalValue(pRecElectrInvTempTable."XML_2.1.1.10 Arrotondamento") +
          GetDecimalValue(pRecElectrInvTempTable."XML_2.1.1.9 Imp. Tot. Doc.");

        pRecElectrInvTempTable."Buy-from Vendor No." := GetVendorNo(
          pRecElectrInvTempTable."XML_1.2.1.1.1 IdPaese",
          pRecElectrInvTempTable."XML_1.2.1.1.2 IdCodice",
          pRecElectrInvTempTable."XML_1.2.1.2 CodiceFiscale");

        IF pRecElectrInvTempTable."Buy-from Vendor No." <> '' THEN BEGIN
            SetVendorData(pRecElectrInvTempTable."Buy-from Vendor No.", pRecElectrInvTempTable);
        END;

        pRecElectrInvTempTable."Electr. Doc.  No." := pRecElectrInvTempTable."XML_1.1.2 Progr. Invio";
        pRecElectrInvTempTable."External Document No." := pRecElectrInvTempTable."XML_2.1.1.4 Numero";
        pRecElectrInvTempTable."CIG Code" := pRecElectrInvTempTable."XML_2.1.2.6 CodiceCIG";
        pRecElectrInvTempTable."CUP Code" := pRecElectrInvTempTable."XML_2.1.2.7 CodiceCUP";

        pRecElectrInvTempTable.MODIFY;
    end;

    local procedure GetDocumentType(pTxtDocumentType: Text) rIntValue: Integer
    var
        lRecPurchaseHeader: Record "Purchase Header";
    begin
        /*
          <Tipo Documento>
            TD01: fattura
            TD02: acconto/anticipo su fattura
            TD03: acconto/anticipo su parcella
            TD04: nota di credito
            TD05: nota di debito
            TD06: parcella
        */
        rIntValue := 0;
        CASE pTxtDocumentType OF
            'TD04', 'TD08':
                rIntValue := lRecPurchaseHeader."Document Type"::"Credit Memo";
                //'TD01','TD02':
            ELSE
                rIntValue := lRecPurchaseHeader."Document Type"::Invoice;
        END;

    end;

    local procedure GetDateValue(pTxtDateString: Text) rDatValue: Date
    var
        lIntYear: Integer;
        lIntMonth: Integer;
        lIntDay: Integer;
    begin
        rDatValue := 0D;
        IF STRLEN(pTxtDateString) = 10 THEN BEGIN
            lIntYear := 0;
            lIntMonth := 0;
            lIntDay := 0;
            IF EVALUATE(lIntYear, COPYSTR(pTxtDateString, 1, 4)) AND
               EVALUATE(lIntMonth, COPYSTR(pTxtDateString, 6, 2)) AND
               EVALUATE(lIntDay, COPYSTR(pTxtDateString, 9, 2)) THEN
                rDatValue := DMY2DATE(lIntDay, lIntMonth, lIntYear);
        END;
    end;

    local procedure GetDecimalValue(pTxtDecimalString: Text) rDecValue: Decimal
    var
        lIntInteger: Integer;
        lIntDecimal: Decimal;
        lIntSign: Integer;
        lIntPosDot: Integer;
    begin
        rDecValue := 0;

        lIntInteger := 0;
        lIntDecimal := 0;
        //>JM-20190522
        pTxtDecimalString := DELCHR(pTxtDecimalString, '<>');
        //<JM-20190522
        IF pTxtDecimalString <> '' THEN BEGIN
            lIntSign := 1;
            IF COPYSTR(pTxtDecimalString, 1, 1) = '-' THEN BEGIN
                lIntSign := -1;
                pTxtDecimalString := COPYSTR(pTxtDecimalString, 2);
            END;
            lIntPosDot := STRPOS(pTxtDecimalString, '.');
            IF lIntPosDot = 0 THEN BEGIN
                EVALUATE(lIntInteger, pTxtDecimalString);
            END ELSE BEGIN
                EVALUATE(lIntInteger, COPYSTR(pTxtDecimalString, 1, lIntPosDot - 1));
                EVALUATE(lIntDecimal, COPYSTR(pTxtDecimalString, lIntPosDot + 1));
                lIntDecimal /= POWER(10, STRLEN(pTxtDecimalString) - lIntPosDot);
            END;

            rDecValue := lIntInteger + lIntDecimal;
            rDecValue *= lIntSign;
        END;
    end;

    local procedure GetVendorNo(pTxtCountryCode: Text; pTxtVatNumber: Text; pTxtFiscalCode: Text) rCodeValue: Code[20]
    var
        lRecVendor: Record Vendor;
    begin
        rCodeValue := '';

        lRecVendor.RESET;
        lRecVendor.SETFILTER(lRecVendor."Blocked", '<>%1', lRecVendor.Blocked::All);
        IF rCodeValue = '' THEN BEGIN
            lRecVendor.SETRANGE(lRecVendor."Country/Region Code", pTxtCountryCode);
            lRecVendor.SETRANGE(lRecVendor."VAT Registration No.", pTxtVatNumber);
            IF (lRecVendor.COUNT = 1) AND (lRecVendor.FINDFIRST) THEN
                rCodeValue := lRecVendor."No.";
        END;

        IF rCodeValue = '' THEN BEGIN
            lRecVendor.SETRANGE(lRecVendor."Country/Region Code");
            IF (lRecVendor.COUNT = 1) AND (lRecVendor.FINDFIRST) THEN
                rCodeValue := lRecVendor."No.";
        END;

        IF rCodeValue = '' THEN BEGIN
            lRecVendor.SETRANGE(lRecVendor."VAT Registration No.", pTxtCountryCode + pTxtVatNumber);
            IF (lRecVendor.COUNT = 1) AND (lRecVendor.FINDFIRST) THEN
                rCodeValue := lRecVendor."No.";
        END;

        IF rCodeValue = '' THEN BEGIN
            lRecVendor.SETRANGE(lRecVendor."VAT Registration No.");
            lRecVendor.SETRANGE(lRecVendor."Country/Region Code", pTxtCountryCode);
            lRecVendor.SETRANGE(lRecVendor."Fiscal Code", pTxtVatNumber);
            IF (lRecVendor.COUNT = 1) AND (lRecVendor.FINDFIRST) THEN
                rCodeValue := lRecVendor."No.";
        END;

        IF rCodeValue = '' THEN BEGIN
            lRecVendor.SETRANGE(lRecVendor."Country/Region Code");
            lRecVendor.SETRANGE(lRecVendor."Fiscal Code", pTxtVatNumber);
            IF (lRecVendor.COUNT = 1) AND (lRecVendor.FINDFIRST) THEN
                rCodeValue := lRecVendor."No.";
        END;

        IF rCodeValue = '' THEN BEGIN
            lRecVendor.SETRANGE(lRecVendor."Fiscal Code", pTxtFiscalCode);
            IF (lRecVendor.COUNT = 1) AND (lRecVendor.FINDFIRST) THEN
                rCodeValue := lRecVendor."No.";
        END;
    end;

    local procedure CreatePurchaseHeader(var pRecElectrInvTempTable: Record "Electr. Doc. Temp. Header")
    var
        lRecPurchaseHeader: Record "Purchase Header";
    begin

        IF (pRecElectrInvTempTable.FINDSET) THEN BEGIN
            REPEAT
                SavePurchaseHeader(pRecElectrInvTempTable);

            UNTIL pRecElectrInvTempTable.NEXT = 0;
        END;
    end;

    local procedure SavePurchaseHeader(var pRecElectrInvTempTable: Record "Electr. Doc. Temp. Header")
    var
        lRecPurchaseHeader: Record "Purchase Header";
        lRecCurrency: Record "Currency";
    begin

        lRecPurchaseHeader.RESET;
        lRecPurchaseHeader.INIT;
        //>JM-FM20190214
        lRecPurchaseHeader.SetHideValidationDialog(TRUE);
        //<JM-FM20190214
        lRecPurchaseHeader."Document Type" := pRecElectrInvTempTable."Document Type";
        lRecPurchaseHeader.INSERT(TRUE);

        lRecPurchaseHeader.VALIDATE(lRecPurchaseHeader."Buy-from Vendor No.", pRecElectrInvTempTable."Buy-from Vendor No.");
        lRecPurchaseHeader.VALIDATE(lRecPurchaseHeader."Pay-to Vendor No.", pRecElectrInvTempTable."Buy-from Vendor No.");
        lRecPurchaseHeader.MODIFY;

        IF lRecPurchaseHeader."Buy-from Address" <> pRecElectrInvTempTable."Buy-from Address" THEN
            lRecPurchaseHeader.VALIDATE(lRecPurchaseHeader."Buy-from Address", pRecElectrInvTempTable."Buy-from Address");
        IF lRecPurchaseHeader."Buy-from City" <> pRecElectrInvTempTable."Buy-from City" THEN
            lRecPurchaseHeader.VALIDATE(lRecPurchaseHeader."Buy-from City", pRecElectrInvTempTable."Buy-from City");
        IF lRecPurchaseHeader."Buy-from County" <> pRecElectrInvTempTable."Buy-from County" THEN
            lRecPurchaseHeader.VALIDATE(lRecPurchaseHeader."Buy-from County", pRecElectrInvTempTable."Buy-from County");
        IF lRecPurchaseHeader."Buy-from Post Code" <> pRecElectrInvTempTable."Buy-from Post Code" THEN
            lRecPurchaseHeader.VALIDATE(lRecPurchaseHeader."Buy-from Post Code", pRecElectrInvTempTable."Buy-from Post Code");
        //>JM-FM20190219
        IF pRecElectrInvTempTable."Currency Code" <> '' THEN BEGIN
            //BC-MIG-TODO            lRecCurrency.RESET;
            //BC-MIG-TODO            lRecCurrency.SETRANGE(lRecCurrency."ISO Code", pRecElectrInvTempTable."Currency Code");
            //BC-MIG-TODO            IF lRecCurrency.FINDFIRST THEN
            //BC-MIG-TODO                lRecPurchaseHeader.VALIDATE(lRecPurchaseHeader."Currency Code", lRecCurrency.Code);
        END;
        //<JM-FM20190219

        lRecPurchaseHeader.VALIDATE(lRecPurchaseHeader."Posting Date", pRecElectrInvTempTable."Posting Date");
        lRecPurchaseHeader.VALIDATE(lRecPurchaseHeader."Document Date", pRecElectrInvTempTable."Document Date");

        IF lRecPurchaseHeader."Document Type" = lRecPurchaseHeader."Document Type"::Invoice THEN
            lRecPurchaseHeader."Vendor Invoice No." := pRecElectrInvTempTable."Vendor Invoice No."
        ELSE
            IF lRecPurchaseHeader."Document Type" = lRecPurchaseHeader."Document Type"::"Credit Memo" THEN
                lRecPurchaseHeader."Vendor Cr. Memo No." := pRecElectrInvTempTable."Vendor Cr. Memo No.";

        lRecPurchaseHeader.VALIDATE(lRecPurchaseHeader."Check Total", pRecElectrInvTempTable."Check Total");

        lRecPurchaseHeader.VALIDATE(lRecPurchaseHeader."Barcode Invoice Document", pRecElectrInvTempTable.Barcode);

        lRecPurchaseHeader.MODIFY(TRUE);
        //>JM-FM20190214
        lRecPurchaseHeader.SetHideValidationDialog(TRUE);
        //<JM-FM20190214

        pRecElectrInvTempTable."Reg. Source No." := DATABASE::"Purchase Header";
        pRecElectrInvTempTable."Reg. Document No." := lRecPurchaseHeader."No.";
        pRecElectrInvTempTable."Reg. Document Type" := lRecPurchaseHeader."Document Type";
        pRecElectrInvTempTable."Reg. Date" := TODAY;
        pRecElectrInvTempTable."Reg. Time" := TIME;
        pRecElectrInvTempTable."Reg. User Name" := USERID;
        pRecElectrInvTempTable.MODIFY;
    end;

    local procedure RemoveNamespace(pTxtTag: Text): Text
    var
        lIntPosDot: Integer;
        lIntLength: Integer;
        lTxtNewTag: Text;
    begin
        lIntPosDot := STRPOS(pTxtTag, ':');
        IF lIntPosDot = 0 THEN
            EXIT(pTxtTag);

        lIntLength := STRLEN(pTxtTag);
        lTxtNewTag := COPYSTR(pTxtTag, (lIntPosDot + 1), lIntLength - lIntPosDot);
        EXIT(lTxtNewTag);
    end;

    procedure GetXmlTagValueFromFileText(pTxtFileText: Text; pTxtTag: Text) rTxtValue: Text
    var
        lTxtEnvelopeXML: Text;
        lIntPosition: Integer;
        lTxtXmlHeaderTag: Text;
    begin
        rTxtValue := '';
        //Normalizzazione XML
        lTxtEnvelopeXML := pTxtFileText;
        lTxtXmlHeaderTag := '?>';
        REPEAT
            lIntPosition := STRPOS(lTxtEnvelopeXML, lTxtXmlHeaderTag);
            IF lIntPosition > 0 THEN
                lTxtEnvelopeXML := COPYSTR(lTxtEnvelopeXML, lIntPosition + STRLEN(lTxtXmlHeaderTag));
        UNTIL lIntPosition <= 0;
        lIntPosition := STRPOS(lTxtEnvelopeXML, '<');
        lTxtEnvelopeXML := COPYSTR(lTxtEnvelopeXML, lIntPosition);

        GetXmlTagValue(rTxtValue, pTxtTag, lTxtEnvelopeXML);
    end;

    local procedure _XML_()
    begin
    end;

    local procedure ClearUTF8BOMSymbols(var XmlText: Text)
    var
        UTF8Encoding: DotNet "System.Text.UTF8Encoding";
        ByteOrderMarkUtf8: Text;
    begin
        UTF8Encoding := UTF8Encoding.UTF8Encoding;
        ByteOrderMarkUtf8 := UTF8Encoding.GetString(UTF8Encoding.GetPreamble);
        IF STRPOS(XmlText, ByteOrderMarkUtf8) = 1 THEN
            XmlText := DELSTR(XmlText, 1, STRLEN(ByteOrderMarkUtf8));
    end;

    [TryFunction]
    procedure LoadXMLDocumentFromText(XmlText: Text; var XmlDocument: DotNet XmlDocument)
    var
        XmlReaderSettings: DotNet XmlReaderSettings;
    begin
        LoadXmlDocFromText(XmlText, XmlDocument, XmlReaderSettings.XmlReaderSettings);
    end;

    local procedure LoadXmlDocFromText(XmlText: Text; var XmlDocument: DotNet XmlDocument; XmlReaderSettings: DotNet XmlReaderSettings)
    var
        StringReader: DotNet StringReader;
        XmlTextReader: DotNet "System.Xml.XmlTextReader";
    begin
        XmlDocument := XmlDocument.XmlDocument;

        IF XmlText = '' THEN
            EXIT;

        ClearUTF8BOMSymbols(XmlText);
        StringReader := StringReader.StringReader(XmlText);
        XmlTextReader := XmlTextReader.Create(StringReader, XmlReaderSettings);
        XmlDocument.Load(XmlTextReader);
        XmlTextReader.Close;
        StringReader.Close;
    end;

    local procedure RemoveComments(var pTxtXml: Integer)
    var
        lTxtStartComment: Text;
        lTxtEndComment: Text;
        lIntStartComment: Integer;
        lIntEndComment: Integer;
    begin
        //>JM-FM20190408
        lTxtStartComment := '<!--';
        lTxtEndComment := '-->';
        //>COMMENT-FIX
        /*
        lTxtXmlCommentStartTag := 'FatturaElettronica';
        lTxtXmlCommentEndTag := '-->';
        REPEAT
          //Controllo commenti
          lIntPosition := STRPOS(UPPERCASE(lTxtEnvelopeXML), UPPERCASE(lTxtXmlCommentStartTag));
          lIntPositionEnd := STRPOS(lTxtEnvelopeXML, lTxtXmlCommentEndTag);
          IF (lIntPosition > lIntPositionEnd) AND (lIntPositionEnd > 0) THEN //Se il commento è in testa lo elimino
            lTxtEnvelopeXML := COPYSTR(lTxtEnvelopeXML, lIntPositionEnd + STRLEN(lTxtXmlCommentEndTag));
          lTxtEnvelopeXML := DELCHR(lTxtEnvelopeXML,'<>',' ');
        UNTIL ((lIntPosition > lIntPositionEnd) OR (lIntPositionEnd = 0));
        */
        //<COMMENT-FIX


        //<JM-FM20190408

    end;

    [TryFunction]
    local procedure GetXmlTagValueWithLength(var pTxtResult: Text; pTxtTag: Text; pTxtXml: Text; pIntLength: Integer; bBlnClearSpace: Boolean)
    var
        lTxtXML: Text;
        lIntIndex: Integer;
        lIntLastTag: Integer;
        lDntString: DotNet "String";
        lDntArray: DotNet Array;
        lDntSeparator: DotNet String;
        XmlDocument: DotNet XmlDocument;
        XmlDoc: Codeunit "XML DOM Management";
        XmlNode: DotNet XmlNode;
        lTxtValue: Text;
    begin
        //>JM-FM20190506
        pTxtResult := '';
        lTxtXML := pTxtXml;
        IF lTxtXML = '' THEN
            EXIT;

        LoadXMLDocumentFromText(lTxtXML, XmlDocument);
        XmlNode := XmlDocument.FirstChild;


        lDntString := (pTxtTag);
        lDntSeparator := '/';
        lDntArray := lDntString.Split(lDntSeparator.ToCharArray());
        lIntLastTag := lDntArray.Length() - 1;
        FOR lIntIndex := 0 TO lIntLastTag DO BEGIN
            GetXmlTagNode(lDntArray.GetValue(lIntIndex), XmlNode);
            IF ISNULL(XmlNode) THEN
                EXIT;
            IF lIntIndex = lIntLastTag THEN BEGIN
                lTxtValue := XmlNode.InnerText;
                IF bBlnClearSpace THEN
                    lTxtValue := DELCHR(lTxtValue, '<>', ' ');
                pTxtResult := COPYSTR(lTxtValue, 1, pIntLength);
            END;
        END;
        //<JM-FM20190506
    end;
}

