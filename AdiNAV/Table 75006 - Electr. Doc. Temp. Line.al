table 75006 "Electr. Doc. Temp. Line"
{
    // version ADI.003


    fields
    {
        field(1; "Source No."; Integer)
        {
            Caption = 'Source No.';
            Description = 'ADI1.0';
        }
        field(2; "Document No."; Code[20])
        {
            Caption = 'Document No.';
            Description = 'ADI1.0';
        }
        field(3; IdUnivoco; Code[20])
        {
            Caption = 'IdUnivoco';
            Description = 'ADI1.0';
        }
        field(4; "Line No."; Integer)
        {
            Caption = 'Nr. Riga';
        }
        field(100; "Reg. Date"; Date)
        {
            Caption = 'Reg. Date';
            Description = 'ADI3.0';
        }
        field(101; "Reg. Time"; Time)
        {
            Caption = 'Reg. Time';
            Description = 'ADI3.0';
        }
        field(102; "Reg. User Name"; Code[50])
        {
            Caption = 'User Name';
            Description = 'ADI3.0';
        }
        field(103; "Reg. Source No."; Integer)
        {
            Caption = 'Reg. Nr. Sorgente';
            Description = 'ADI3.0';
        }
        field(104; "Reg. Document No."; Code[20])
        {
            Caption = 'Document No.';
            Description = 'ADI3.0';
        }
        field(105; "Reg. Document Type"; Integer)
        {
            Caption = 'Reg. Document Type';
            Description = 'ADI3.0';
        }
        field(106; "Reg. Line No."; Integer)
        {
            Caption = 'Reg. Nr. Riga';
            Description = 'ADI3.0';
        }
        field(1000; "XML_2.2.1.1 NumeroLinea"; Text[4])
        {
        }
        field(1001; "XML_2.2.1.2 TipoCesPrestaz"; Text[2])
        {
        }
        field(1002; "XML_2.2.1.3.1 CodiceTipo"; Text[35])
        {
        }
        field(1003; "XML_2.2.1.3.2 CodiceValore"; Text[35])
        {
        }
        field(1004; "XML_2.2.1.4 Descrizione"; Text[250])
        {
            Description = ' (campo XML da 1000 caratteri)';
        }
        field(1005; "XML_2.2.1.5 Quantita"; Text[21])
        {
        }
        field(1006; "XML_2.2.1.6 UnitaMisura"; Text[10])
        {
        }
        field(1007; "XML_2.2.1.9 PrezzoUnitario"; Text[21])
        {
        }
        field(1008; "XML_2.2.1.10.1 ScMgTipo"; Text[2])
        {
        }
        field(1009; "XML_2.2.1.10.2 ScMgPerc"; Text[6])
        {
        }
        field(1010; "XML_2.2.1.10.3 ScMgImp"; Text[15])
        {
        }
        field(1011; "XML_2.2.1.11 PrezzoTotale"; Text[21])
        {
        }
        field(1012; "XML_2.2.1.12 AliquotaIVA"; Text[6])
        {
        }
        field(50000; "Table Id"; Integer)
        {
            Caption = 'Id Tabella';
        }
        field(50001; "Document Type"; Option)
        {
            Caption = 'Document Type';
            OptionCaption = 'Quote,Order,Invoice,Credit Memo,Blanket Order,Return Order';
            OptionMembers = Quote,"Order",Invoice,"Credit Memo","Blanket Order","Return Order";
        }
        field(50002; "Document Line No."; Integer)
        {
            Caption = 'Buy-from Vendor No.';
            Editable = false;
            TableRelation = Vendor;
        }
        field(50003; Type; Option)
        {
            Caption = 'Type';
            OptionCaption = ' ,G/L Account,Item,,Fixed Asset,Charge (Item)';
            OptionMembers = " ","G/L Account",Item,,"Fixed Asset","Charge (Item)";

            trigger OnValidate()
            var
            //                TempPurchLine: Record "39" temporary;
            begin
            end;
        }
        field(50004; "No."; Code[20])
        {
            Caption = 'No.';
            //            TableRelation = IF (Type=CONST(" ")) "Standard Text"
            //                            ELSE IF (Type=CONST(G/L Account)) "G/L Account" WHERE (Direct Posting=CONST(Yes),
            //                                                                                   Account Type=CONST(Posting),
            //                                                                                   Show on Purch. Documents=FILTER(' '|Yes),
            //                                                                                   Blocked=CONST(No))
            //                                                                                   ELSE IF (Type=CONST(G/L Account)) "G/L Account"
            //                                                                                   ELSE IF (Type=CONST(Item)) Item
            //                                                                                   ELSE IF (Type=CONST(Fixed Asset)) "Fixed Asset"
            //                                                                                   ELSE IF (Type=CONST("Charge (Item)")) "Item Charge";
            //            ValidateTableRelation = false;

            trigger OnValidate()
            var
            // TempPurchLine: Record "39" temporary;
            // StandardText: Record "7";
            // FixedAsset: Record "5600";
            // PrepmtMgt: Codeunit "441";
            // TypeHelper: Codeunit "10";
            // _PE_: Integer;
            // VendorRatingSetup: Record "18006540";
            // VendorRatingMgt: Codeunit "18006565";
            begin
            end;
        }
        field(50005; Description; Text[50])
        {
            Caption = 'Description';
            //            TableRelation = IF (Type=CONST(G/L Account)) "G/L Account" WHERE (Direct Posting=CONST(Yes),
            //                                                                              Account Type=CONST(Posting),
            //                                                                              Blocked=CONST(No))
            //                                                                              ELSE IF (Type=CONST(G/L Account)) "G/L Account"
            //                                                                              ELSE IF (Type=CONST(Item)) Item
            //                                                                              ELSE IF (Type=CONST(Fixed Asset)) "Fixed Asset"
            //                                                                              ELSE IF (Type=CONST("Charge (Item)")) "Item Charge";
            //            ValidateTableRelation = false;

            trigger OnValidate()
            var
            //                Item: Record "27";
            //                TypeHelper: Codeunit "10";
            //                ReturnValue: Text[50];
            begin
            end;
        }
        field(50006; "Unit of Measure"; Text[10])
        {
            Caption = 'Unit of Measure';
        }
        field(50007; Quantity; Decimal)
        {
            Caption = 'Quantity';
            DecimalPlaces = 0 : 5;
        }
        field(50011; Amount; Decimal)
        {
            AutoFormatType = 1;
            Caption = 'Amount';
            Editable = false;
        }
        field(50012; "VAT %"; Decimal)
        {
            Caption = 'VAT %';
            DecimalPlaces = 0 : 5;
            Editable = false;
        }
        field(50013; "Direct Unit Cost"; Decimal)
        {
            AutoFormatType = 2;
            Caption = 'Direct Unit Cost';
        }
    }

    keys
    {
        key(Key1; "Source No.")
        {
        }
    }

    fieldgroups
    {
    }
}

