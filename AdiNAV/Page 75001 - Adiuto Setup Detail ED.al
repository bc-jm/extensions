page 75001 "Adiuto Setup Detail ED"
{
    // version ADI.003

    Caption = 'Adiuto Setup Detail';
    PageType = ListPart;
    SourceTable = "Adiuto Setup Detail ED";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Table Id"; "Table Id")
                {
                }
                field("Document Type"; "Document Type")
                {
                }
                field("Create Document"; "Create Document")
                {
                }
                field("Id Family Document"; "Id Family Document")
                {
                    AssistEdit = true;

                    trigger OnAssistEdit()
                    begin
                        SelectFamily;
                    end;
                }
                field("Name Family Document"; "Name Family Document")
                {

                    trigger OnValidate()
                    begin
                        Description := "Name Family Document";
                    end;
                }
                field(Description; Description)
                {
                }
                field(Phantom; Phantom)
                {
                }
                field("Report Id"; "Report Id")
                {
                }
                field("El. Doc. Att. Rpt. Setup Code"; "El. Doc. Att. Rpt. Setup Code")
                {
                }
                field("File Extension"; "File Extension")
                {
                }
                field("Total Detail Rows"; "Total Detail Rows")
                {

                }
                field("XML Document"; "XML Document")
                {
                }
                field("El. Doc. Status Fld. Id"; "El. Doc. Status Fld. Id")
                {
                    AssistEdit = true;

                    trigger OnAssistEdit()
                    begin
                        SelectField("El. Doc. Status Fld. Id", "El. Doc. Status Fld. Name");
                    end;
                }
                field("El. Doc. Status Fld. Name"; "El. Doc. Status Fld. Name")
                {
                    Editable = false;
                }
                field("El. Doc. Barcode Fld. Id"; "El. Doc. Barcode Fld. Id")
                {
                    AssistEdit = true;

                    trigger OnAssistEdit()
                    begin
                        SelectField("El. Doc. Barcode Fld. Id", "El. Doc. Barcode Fld. Name");
                    end;
                }
                field("El. Doc. Barcode Fld. Name"; "El. Doc. Barcode Fld. Name")
                {
                    Editable = false;
                }
                field("El. Doc. B2B Fld. Id"; "El. Doc. B2B Fld. Id")
                {
                    AssistEdit = true;

                    trigger OnAssistEdit()
                    begin
                        SelectField("El. Doc. B2B Fld. Id", "El. Doc. B2B Fld. Name");
                    end;
                }
                field("El. Doc. B2B Fld. Name"; "El. Doc. B2B Fld. Name")
                {
                    Editable = false;
                }
                field("El. Doc. Attachment Report Id"; "El. Doc. Attachment Report Id")
                {
                }
                field("El. Doc. Trasmit. Fld. Id"; "El. Doc. Trasmit. Fld. Id")
                {

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        SelectField("El. Doc. Trasmit. Fld. Id", "El. Doc. Trasmit. Fld. Name");
                    end;
                }
                field("El. Doc. Trasmit. Fld. Name"; "El. Doc. Trasmit. Fld. Name")
                {
                    Editable = false;
                }
                field("El. Doc. VAT Reg. Fld. Id"; "El. Doc. VAT Reg. Fld. Id")
                {

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        SelectField("El. Doc. VAT Reg. Fld. Id", "El. Doc. VAT Reg. Fld. Name");
                    end;
                }
                field("El. Doc. VAT Reg. Fld. Name"; "El. Doc. VAT Reg. Fld. Name")
                {
                    Editable = false;
                }
                field("El. Doc. Progressive Fld. Id"; "El. Doc. Progressive Fld. Id")
                {

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        SelectField("El. Doc. Progressive Fld. Id", "El. Doc. Progressive Fld. Name");
                    end;
                }
                field("El. Doc. Progressive Fld. Name"; "El. Doc. Progressive Fld. Name")
                {
                    Editable = false;
                }
                field("El. Doc. Cust. Comp. Fld. Id"; "El. Doc. Cust. Comp. Fld. Id")
                {

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        SelectField("El. Doc. Cust. Comp. Fld. Id", "El. Doc. Cust. Comp. Fld. Name");
                    end;
                }
                field("El. Doc. Cust. Comp. Fld. Name"; "El. Doc. Cust. Comp. Fld. Name")
                {
                    Editable = false;
                }
                field(Canceled; Canceled)
                {
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            group(Navigate)
            {
                Caption = 'Navigate';
                action(OpenDetail)
                {
                    CaptionML = ENU = 'Open Detail', ITA = 'Apri dettaglio';
                    Image = ViewDetails;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    PromotedOnly = true;

                    trigger OnAction()
                    begin
                        ShowDetailLines(Rec);
                    end;
                }
            }
        }
    }
    var
        gTmpRecAdiutoSetupDetail: Record "Adiuto Setup Detail ED" temporary;

    local procedure SelectFamily()
    var
        lCduAdiutoNetWebService: Codeunit "Adiuto Net Web Service ED";
        lTxtXml: Text;
        lCduXMLBufferWriter: Codeunit "XML Buffer Writer";
        lRecXMLBuffer: Record "XML Buffer";
        lPagAdiutoFamilyList: Page "Adiuto Family List ED";
    begin

        //>AB20180706
        lPagAdiutoFamilyList.SetFamily(0);
        lPagAdiutoFamilyList.EDITABLE(FALSE);
        lPagAdiutoFamilyList.LOOKUPMODE(TRUE);
        IF lPagAdiutoFamilyList.RUNMODAL = ACTION::LookupOK THEN BEGIN
            //lPagAdiutoFamilyList.EDITABLE(FALSE);
            //IF lPagAdiutoFamilyList.RUNMODAL = ACTION::OK THEN BEGIN
            lPagAdiutoFamilyList.GetFamilyValues("Id Family Document", "Name Family Document", Description);
            MODIFY;
        END;
        //<AB20180706
    end;

    local procedure SelectField(var pTxtFieldId: Integer; var pTxtFieldDescription: Text)
    var
        lCduAdiutoNetWebService: Codeunit "Adiuto Net Web Service ED";
        lTxtXml: Text;
        lCduXMLBufferWriter: Codeunit "XML Buffer Writer";
        lRecXMLBuffer: Record "XML Buffer";
        lPagAdiutoFamilyList: Page "Adiuto Family List ED";
    begin

        //>AB20180706
        TESTFIELD("Id Family Document");
        lPagAdiutoFamilyList.SetFamily("Id Family Document");
        lPagAdiutoFamilyList.EDITABLE(FALSE);
        lPagAdiutoFamilyList.LOOKUPMODE(TRUE);
        IF lPagAdiutoFamilyList.RUNMODAL = ACTION::LookupOK THEN BEGIN
            lPagAdiutoFamilyList.GetFieldValues(pTxtFieldId, pTxtFieldDescription);
            MODIFY;
        END;
        //<AB20180706
    end;

    local procedure ShowDetailLines(pRecAdiutoSetupDetail: Record "Adiuto Setup Detail ED")
    var
        lRecAdiutoSetupDetailLines: Record "Adiuto Setup Detail Lines ED";
        lPagAdiutoSetupDetailLines: Page "Adiuto Setup Detail Lines ED";
    begin
        lRecAdiutoSetupDetailLines.RESET;
        lRecAdiutoSetupDetailLines.SETRANGE("Primary Key", "Primary Key");
        lRecAdiutoSetupDetailLines.SETRANGE("Line No.", "Line No.");
        lPagAdiutoSetupDetailLines.SETRECORD(lRecAdiutoSetupDetailLines);
        lPagAdiutoSetupDetailLines.SETTABLEVIEW(lRecAdiutoSetupDetailLines);
        lPagAdiutoSetupDetailLines.RUNMODAL;
    end;

}

