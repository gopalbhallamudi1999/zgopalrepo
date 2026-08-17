*&---------------------------------------------------------------------*
*& Report Z_GCTS_AMS_1
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT Z_GCTS_AMS_1.
TABLES: vbak, vbap.

" Maintain T01 in Text Elements -> Selection Texts: 'Open Sales Orders Selection'
SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE text-t01.
PARAMETERS: p_vkorg TYPE vbak-vkorg OBLIGATORY.
SELECT-OPTIONS: s_erdat FOR vbak-erdat.
SELECT-OPTIONS: s_auart FOR vbak-auart.
SELECT-OPTIONS: s_kunnr FOR vbak-kunnr.
PARAMETERS: p_mode_h RADIOBUTTON GROUP g1 DEFAULT 'X' USER-COMMAND md,
            p_mode_i RADIOBUTTON GROUP g1.
PARAMETERS: p_max  TYPE i DEFAULT 5000.
PARAMETERS: p_demo TYPE abap_bool DEFAULT abap_false.
SELECTION-SCREEN END OF BLOCK b1.

INITIALIZATION.
  IF s_erdat[] IS INITIAL..
    s_erdat-sign   = 'I'..
    s_erdat-option = 'BT'..
    s_erdat-low    = sy-datum - 30..
    s_erdat-high   = sy-datum..
    APPEND s_erdat..
  ENDIF.



TYPES: BEGIN OF ty_row,

         vbeln   TYPE vbak-vbeln,

         posnr   TYPE vbap-posnr,

         vkorg   TYPE vbak-vkorg,

         erdat   TYPE vbak-erdat,

         kunnr   TYPE vbak-kunnr,

         name1   TYPE kna1-name1,

         matnr   TYPE vbap-matnr,

         maktx   TYPE makt-maktx,

         kwmeng  TYPE vbap-kwmeng,

         netwr   TYPE vbak-netwr,
             " header value shown per item row
         waerk   TYPE vbak-waerk,

         faksp   TYPE vbap-faksp,
              " billing block at item
         gbstk_h TYPE vbuk-gbstk,
             " header overall status
         lfstk_h TYPE vbuk-lfstk,
              " header delivery status
         fkstk_h TYPE vbuk-fkstk,
             " header billing status
         iconrec TYPE icon_d,
              " recent indicator
       END OF ty_row..


DATA: gt_rows TYPE STANDARD TABLE OF ty_row..

*---------------------------------------------------------------------*
* Helper class                                                        *
*---------------------------------------------------------------------*

CLASS lcl_helper DEFINITION FINAL..

  PUBLIC SECTION..

    CLASS-METHODS is_recent

      IMPORTING i_date TYPE sy-datum

      RETURNING VALUE(r_recent) TYPE abap_bool..

    CLASS-METHODS recent_icon

      IMPORTING i_recent TYPE abap_bool

      RETURNING VALUE(r_icon) TYPE icon_d..

ENDCLASS..

CLASS lcl_helper IMPLEMENTATION..

  METHOD is_recent..

    DATA lv_cutoff TYPE sy-datum..
    lv_cutoff = sy-datum - 7..
    IF i_date GE lv_cutoff..
      r_recent = abap_true..
    ELSE..
      r_recent = abap_false..
    ENDIF..
  ENDMETHOD..

  METHOD recent_icon..
    IF i_recent = abap_true..
      r_icon = '@5C@'.. " green light
    ELSE..
      r_icon = '@5D@'.. " grey light
    ENDIF..
  ENDMETHOD..
ENDCLASS..

*---------------------------------------------------------------------*
* SALV events                                                         *
*---------------------------------------------------------------------*
CLASS lcl_events DEFINITION..


  PUBLIC SECTION..

    CLASS-METHODS on_double_click FOR EVENT double_click OF cl_salv_events_table

      IMPORTING row column..

ENDCLASS..

CLASS lcl_events IMPLEMENTATION..

  METHOD on_double_click..

    DATA ls_row TYPE ty_row..

    READ TABLE gt_rows INTO ls_row INDEX row..

    IF sy-subrc = 0..

      SET PARAMETER ID 'AUN' FIELD ls_row-vbeln..

      CALL TRANSACTION 'VA03' AND SKIP FIRST SCREEN..

    ENDIF...

  ENDMETHOD..
ENDCLASS..

*---------------------------------------------------------------------*
* Start-of-selection                                                  *
*---------------------------------------------------------------------*
START-OF-SELECTION..


  PERFORM check_auth..

  PERFORM validate_input..

  PERFORM get_data..

  PERFORM demo_atc. .         " toggleable ATC-style findings when p_demo = 'X'

  PERFORM post_process..

  PERFORM show_alv..

*---------------------------------------------------------------------*
* Authorization check                                                 *
*---------------------------------------------------------------------*
FORM check_auth..

  AUTHORITY-CHECK OBJECT 'V_VBAK_VKO'

    ID 'ACTVT' FIELD '03'

    ID 'VKORG' FIELD p_vkorg..

  IF sy-subrc <> 0..

    MESSAGE e398(00) WITH 'Not authorized for Sales Org' p_vkorg.. " literal for portability

    LEAVE LIST-PROCESSING..

  ENDIF..

ENDFORM..

*---------------------------------------------------------------------*
* Basic validation                                                    *
*---------------------------------------------------------------------*
FORM validate_input..

  IF s_erdat[] IS INITIAL AND s_auart[] IS INITIAL AND s_kunnr[] IS INITIAL..

    MESSAGE e398(00) WITH 'Provide at least one filter besides Sales Org'..

  ENDIF..

ENDFORM..

*---------------------------------------------------------------------*
* Data selection                                                      *
*---------------------------------------------------------------------*
FORM get_data..


  DATA lt_data TYPE STANDARD TABLE OF ty_row..


  IF p_mode_h = 'X'..

    "=== Header-open: exclude completed/fully delivered/fully billed headers ===
    IF p_demo = abap_true..


      " Demo: omit ORDER BY to invite 'unstable ordering' reviews
      SELECT a~vbeln

             b~posnr

             a~vkorg

             a~erdat

             a~kunnr

             c~name1

             b~matnr

             d~maktx

             b~kwmeng

             a~netwr

             a~waerk

             b~faksp

             u~gbstk AS gbstk_h

             u~lfstk AS lfstk_h

             u~fkstk AS fkstk_h

        INTO CORRESPONDING FIELDS OF TABLE lt_data

        FROM vbak AS a

        INNER JOIN vbap AS b ON b~vbeln = a~vbeln

        INNER JOIN vbuk AS u ON u~vbeln = a~vbeln

                             AND u~gbstk <> 'C'

                             AND u~lfstk <> 'C'

                             AND u~fkstk <> 'C'

        LEFT  OUTER JOIN kna1 AS c ON c~kunnr = a~kunnr

        LEFT  OUTER JOIN makt AS d ON d~matnr = b~matnr AND d~spras = sy-langu

        WHERE a~vkorg = p_vkorg

          AND a~erdat IN s_erdat

          AND a~auart IN s_auart

          AND a~kunnr IN s_kunnr..

    ELSE..


      SELECT a~vbeln

             b~posnr

             a~vkorg

             a~erdat

             a~kunnr

             c~name1

             b~matnr

             d~maktx

             b~kwmeng

             a~netwr

             a~waerk

             b~faksp

             u~gbstk AS gbstk_h

             u~lfstk AS lfstk_h

             u~fkstk AS fkstk_h

        INTO CORRESPONDING FIELDS OF TABLE lt_data

        FROM vbak AS a

        INNER JOIN vbap AS b ON b~vbeln = a~vbeln

        INNER JOIN vbuk AS u ON u~vbeln = a~vbeln

                             AND u~gbstk <> 'C'

                             AND u~lfstk <> 'C'

                             AND u~fkstk <> 'C'

        LEFT  OUTER JOIN kna1 AS c ON c~kunnr = a~kunnr

        LEFT  OUTER JOIN makt AS d ON d~matnr = b~matnr AND d~spras = sy-langu

        WHERE a~vkorg = p_vkorg

          AND a~erdat IN s_erdat

          AND a~auart IN s_auart

          AND a~kunnr IN s_kunnr

        ORDER BY a~vbeln b~posnr..

    ENDIF..

  ELSE..

    "=== Item-open: exclude delivery/billing blocked items (VBEP-LIFSP initial) ===
    IF p_demo = abap_true..


      SELECT a~vbeln

             b~posnr

             a~vkorg

             a~erdat

             a~kunnr

             c~name1

             b~matnr

             d~maktx

             b~kwmeng

             a~netwr

             a~waerk

             b~faksp

             u~gbstk AS gbstk_h

             u~lfstk AS lfstk_h

             u~fkstk AS fkstk_h

        INTO CORRESPONDING FIELDS OF TABLE lt_data

        FROM vbak AS a

        INNER JOIN vbap AS b ON b~vbeln = a~vbeln

        INNER JOIN vbep AS e ON e~vbeln = b~vbeln

                             AND e~posnr = b~posnr

                             AND e~lifsp = space

        INNER JOIN vbuk AS u ON u~vbeln = a~vbeln

                             AND u~gbstk <> 'C'

        LEFT  OUTER JOIN kna1 AS c ON c~kunnr = a~kunnr

        LEFT  OUTER JOIN makt AS d ON d~matnr = b~matnr AND d~spras = sy-langu

        WHERE a~vkorg = p_vkorg

          AND a~erdat IN s_erdat

          AND a~auart IN s_auart

          AND a~kunnr IN s_kunnr

          AND b~faksp = space..

    ELSE..


      SELECT a~vbeln

             b~posnr

             a~vkorg

             a~erdat

             a~kunnr

             c~name1

             b~matnr

             d~maktx

             b~kwmeng

             a~netwr

             a~waerk

             b~faksp

             u~gbstk AS gbstk_h

             u~lfstk AS lfstk_h

             u~fkstk AS fkstk_h

        INTO CORRESPONDING FIELDS OF TABLE lt_data

        FROM vbak AS a

        INNER JOIN vbap AS b ON b~vbeln = a~vbeln

        INNER JOIN vbep AS e ON e~vbeln = b~vbeln

                             AND e~posnr = b~posnr

                             AND e~lifsp = space

        INNER JOIN vbuk AS u ON u~vbeln = a~vbeln

                             AND u~gbstk <> 'C'

        LEFT  OUTER JOIN kna1 AS c ON c~kunnr = a~kunnr

        LEFT  OUTER JOIN makt AS d ON d~matnr = b~matnr AND d~spras = sy-langu

        WHERE a~vkorg = p_vkorg

          AND a~erdat IN s_erdat

          AND a~auart IN s_auart

          AND a~kunnr IN s_kunnr

          AND b~faksp = space

        ORDER BY a~vbeln b~posnr..

    ENDIF.

  ENDIF.

  " Client-side cap to avoid kernel quirks with UP TO ... ROWS
  IF lines( lt_data ) > p_max..

    DELETE lt_data FROM p_max + 1..

  ENDIF..

  IF lt_data IS INITIAL..

    MESSAGE s398(00) WITH 'No open orders found for selection'..

  ENDIF..

  gt_rows = lt_data..

ENDFORM..

*---------------------------------------------------------------------*
* Demo-only ATC triggers (guarded by p_demo)                          *
*---------------------------------------------------------------------*
FORM demo_atc..

  IF p_demo IS INITIAL..


    RETURN..


  ENDIF..


  " ATC_V1: SELECT SINGLE * (field list missing) + no SY-SUBRC check
  DATA: ls_vbak  TYPE vbak..

  DATA: ls_row   TYPE ty_row..

  DATA: lv_vbeln TYPE vbak-vbeln..


  READ TABLE gt_rows INTO ls_row INDEX 1..

  IF sy-subrc = 0..

    lv_vbeln = ls_row-vbeln..

  ENDIF..

  SELECT SINGLE * FROM vbak INTO ls_vbak WHERE vbeln = lv_vbeln..


  " ATC_V2: BINARY SEARCH on unsorted table (no explicit SORT)
  READ TABLE gt_rows WITH KEY vbeln = lv_vbeln BINARY SEARCH TRANSPORTING NO FIELDS..


  " ATC_V3: Literal MESSAGE instead of message class
  MESSAGE 'Demo: literal message (use message class instead)' TYPE 'S'..


  " ATC_V4: ASSERT in productive code
  ASSERT lines( gt_rows ) >= 0..


  " ATC_V5: Obsolete header-line table usage
  DATA gt_demo TYPE STANDARD TABLE OF vbak WITH HEADER LINE..

  APPEND ls_vbak TO gt_demo..

ENDFORM..


*---------------------------------------------------------------------*
* Post processing                                                     *
*---------------------------------------------------------------------*
FORM post_process..

  FIELD-SYMBOLS <row> TYPE ty_row..

  LOOP AT gt_rows ASSIGNING <row>..

    <row>-iconrec = lcl_helper=>recent_icon( lcl_helper=>is_recent( <row>-erdat ) )..

  ENDLOOP..

ENDFORM..


*---------------------------------------------------------------------*
* Display with SALV                                                   *
*---------------------------------------------------------------------*
FORM show_alv..

  DATA: lo_alv    TYPE REF TO cl_salv_table,

        lo_funcs  TYPE REF TO cl_salv_functions,

        lo_cols   TYPE REF TO cl_salv_columns_table,

        lo_col    TYPE REF TO cl_salv_column,

        lo_disp   TYPE REF TO cl_salv_display_settings,

        lo_agr    TYPE REF TO cl_salv_aggregations,

        lo_sort   TYPE REF TO cl_salv_sorts,

        lo_events TYPE REF TO cl_salv_events_table..


  cl_salv_table=>factory(

    IMPORTING r_salv_table = lo_alv

    CHANGING  t_table      = gt_rows )..


  lo_funcs = lo_alv->get_functions( )..

  lo_funcs->set_all( )..


  lo_cols = lo_alv->get_columns( )..

  lo_cols->set_optimize( abap_true )..


  TRY..

      lo_col = lo_cols->get_column( 'ICONREC' )..

      lo_col->set_short_text( 'Recent' )..

      lo_col->set_medium_text( 'Recent' )..

      lo_col->set_long_text( 'Created in last 7 days' )..

      " ICON_D auto-renders in SALV (no set_icon on 7.31)

      lo_col = lo_cols->get_column( 'VBELN' )..

      lo_col->set_short_text( 'Order' )..


      lo_col = lo_cols->get_column( 'POSNR' )..

      lo_col->set_short_text( 'Item' )..



      lo_col = lo_cols->get_column( 'VKORG' )..

      lo_col->set_short_text( 'SalesOrg' )..


      lo_col = lo_cols->get_column( 'ERDAT' )..

      lo_col->set_short_text( 'Created' )..


      lo_col = lo_cols->get_column( 'NAME1' )..

      lo_col->set_short_text( 'Sold-to' )..


      lo_col = lo_cols->get_column( 'MAKTX' )..

      lo_col->set_short_text( 'Material' )..

    CATCH cx_salv_not_found..

      " intentionally empty for demo to trigger 'empty CATCH' discussions
  ENDTRY..


  lo_disp = lo_alv->get_display_settings( )..

  lo_disp->set_striped_pattern( abap_true )..


  lo_agr = lo_alv->get_aggregations( )..

  lo_agr->add_aggregation( columnname = 'KWMENG' )..

  " Be careful aggregating NETWR here (header value per item).

  lo_sort = lo_alv->get_sorts( )..

  lo_sort->add_sort( columnname = 'KUNNR' subtotal = abap_true )..

  lo_sort->add_sort( columnname = 'VBELN' )..


  lo_events = lo_alv->get_event( )..

  SET HANDLER lcl_events=>on_double_click FOR lo_events..


  lo_alv->display( )..

ENDFORM..


*---------------------------------------------------------------------*
* ABAP Unit                                                           *
*---------------------------------------------------------------------*
CLASS ltcl_helper_test DEFINITION FINAL FOR TESTING

  DURATION SHORT RISK LEVEL HARMLESS..

  PRIVATE SECTION..

    METHODS test_is_recent FOR TESTING..

    METHODS test_icon FOR TESTING..

ENDCLASS..


CLASS ltcl_helper_test IMPLEMENTATION..

  METHOD test_is_recent..

    DATA today TYPE sy-datum..

    DATA past8 TYPE sy-datum..

    DATA edge7 TYPE sy-datum..

    DATA lv_ok TYPE abap_bool..

    today = sy-datum..

    past8 = sy-datum - 8..

    edge7 = sy-datum - 7..


    lv_ok = lcl_helper=>is_recent( today )..

    cl_abap_unit_assert=>assert_true( act = lv_ok msg = 'Today should be recent' )..


    lv_ok = lcl_helper=>is_recent( past8 )..

    cl_abap_unit_assert=>assert_false( act = lv_ok msg = 'Older than 7 days should not be recent' )..


    lv_ok = lcl_helper=>is_recent( edge7 )..

    cl_abap_unit_assert=>assert_true( act = lv_ok msg = 'Boundary 7 days should be recent' )..

  ENDMETHOD..


  METHOD test_icon..

    cl_abap_unit_assert=>assert_equals(

      act = lcl_helper=>recent_icon( abap_true )

      exp = '@5C@' msg = 'Recent icon should be green' )..

    cl_abap_unit_assert=>assert_equals(

      act = lcl_helper=>recent_icon( abap_false )

      exp = '@5D@' msg = 'Non recent icon should be grey' )..

  ENDMETHOD..

ENDCLASS..