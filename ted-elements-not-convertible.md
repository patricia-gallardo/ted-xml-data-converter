# TED schema elements which cannot be converted to eForms

This table lists the elements defined in the TED R.2.0.9 schema for Contract Notices, but whose data cannot be converted to any data structures in eForms.


| TED Element | TED schema | Content format Usage | Description | Reason for inability to convert |
| --- | --- | --- | --- | --- |
| CA_ACTIVITY_OTHER | R.2.0.9 | Text | Alternative to CA_ACTIVITY, containing textual description | Cannot convert text to a code |
| CE_ACTIVITY_OTHER | R.2.0.9 | Text | Alternative to CE_ACTIVITY, containing textual description | Cannot convert text to a code |
| CA_TYPE_OTHER | R.2.0.9 | Text | Alternative to CA_TYPE, containing textual description | Cannot convert text to a code |
| CRITERIA_CANDIDATE | R.2.0.9 | Text | Objective criteria for choosing the limited number of candidates | eForms does not record the criteria used for selecting candidates for the second stage |
| NO_OPTIONS | R.2.0.9 | Empty | Information about options | No need to convert as no eForms output is required to state that there are no options available |
| ECONOMIC_CRITERIA_DOC | R.2.0.9 | Text | Selection criteria as stated in the procurement documents | eForms does not allow for Selection Criteria to be contained in external documents |
| TECHNICAL_CRITERIA_DOC | R.2.0.9 | Text | Selection criteria as stated in the procurement documents | eForms does not allow for Selection Criteria to be contained in external documents |
| FT | R.2.0.9 | Text | Subscript and Superscript text within P (paragraph) elements | eForms does not support emphasised text. |
| LEGAL_BASIS_OTHER | R.2.0.9 | Text | LEGAL_BASIS_OTHER contains text which describes the legal basis for the notice | Cannot convert text to a code; eForms uses a codelist for Procedure Legal Basis (BT-01) |
| LOT_COMBINING_CONTRACT_RIGHT | R.2.0.9 | Text | The contracting authority reserves the right to award concessions combining the following lots or groups of lots - Text | Group of Lots described as text cannot be converted into a structural group of lots |
| NO_LOT_DIVISION | R.2.0.9 | Boolean | This contract is not divided into lots | No need to convert as no eForms output is required to state that there is no lot division |
| LOT_DIVISION | R.2.0.9 | Boolean | This contract is divided into lots | There is no equivalent BT to LOT_DIVISION. There are no children of LOT_DIVISION in F03 to convert |
| REFERENCE_TO_LAW | R.2.0.9 | Text | Reference to the relevant law, regulation or administrative provision (Execution of the service is reserved to a particular profession) | eForms does not have a BT to hold the reference to law for reserving the procurement for a particular profession |
| REFERENCE_NUMBER | R.2.0.9 | Text | Reference number (Object section) | eForms does not have a BT to hold a reference number |
| TECHNICAL_CRITERIA_DOC | R.2.0.9 | Text | Selection criteria as stated in the procurement documents | eForms does not allow for Selection Criteria to be contained in external documents |
| PARTICULAR_PROFESSION | R.2.0.9 | Text | Form F12 only: Participation is reserved to a particular profession | Equivalent eForms Reserved Participation (BT-71) is forbidden for Design Contest notices (subtypes 23 and 24) |
| NO_PARTICULAR_PROFESSION | R.2.0.9 | Empty | Form F12 only: Participation is reserved to a particular profession | Equivalent eForms Reserved Participation (BT-71) is forbidden for Design Contest notices (subtypes 23 and 24) |
| URL_NATIONAL_PROCEDURE | R.2.0.9 | URL | Information about national procedures is available at (URL) | eForms does not have a BT to hold a national procedure URL |
| OBJECT_CONTRACT/VAL_RANGE_TOTAL/HIGH
OBJECT_CONTRACT/VAL_RANGE_TOTAL/LOW | R.2.0.9 | Value | Total value of the procurement (excluding VAT) - Lowest offer / Highest offer taken into consideration | eForms does not have a BT to hold range values for offers across all lots |
| AWARDED_CONTRACT/VAL_ESTIMATED_TOTAL | R.2.0.9 | Value | Initial estimated total value of the contract / lot (for framework agreements or dynamic purchasing systems – estimated total maximum value for the entire duration of this lot) | When the notice is not part of a Framework Agreement or DPS, there is no eForms equivalent of this element |
| DATE_AWARD_SCHEDULED | R.2.0.9 | Date | Present in forms F01, F04, F21 and F22 | eForms does not have a BT to hold a DATE_AWARD_SCHEDULED |
