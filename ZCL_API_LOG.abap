class ZCL_API_LOG definition
  public
  create public .

public section.
  type-pools ABAP .

  constants:
    BEGIN OF mc_sbal_profile,
      single TYPE char1 VALUE '1',                          "#EC NOTEXT
      detlevel TYPE char1 VALUE '2',                          "#EC NOTEXT
      popup TYPE char1 VALUE '3',                             "#EC NOTEXT
      no_tree TYPE char1 VALUE '4',                           "#EC NOTEXT
    END OF mc_sbal_profile .
  constants:
    BEGIN OF mc_window_action,
      okay TYPE sy-ucomm VALUE '&ONT',                          "#EC NOTEXT
      cancel TYPE sy-ucomm VALUE '&F12',                          "#EC NOTEXT
    END OF mc_window_action .
  data NEW_MESSAGE type STRING .
  data DETLEVEL type BALLEVEL .
  data PROBCLASS type BALPROBCL .
  data ALSORT type BALSORT .
  data TIME_STMP type BALTIMSTMP .
  data MSG_COUNT type BALCNTCUM .
  data CONTEXT type BAL_S_CONT .
  data PARAMS type BAL_S_PARM .

  events ON_CONTENT_CHANGED .

  methods CONSTRUCTOR
    importing
      !IV_HANDLER type BALLOGHNDL
      !IV_TIMESTAMP type BALTIMSTMP optional .
  class-methods CREATE_LOG
    importing
      value(IV_OBJECT) type BALOBJ_D optional
      value(IV_SUBOBJECT) type BALSUBOBJ optional
      value(IV_EXTNUMBER) type CLIKE optional
      !IV_INSTANCE_TYPE type CLIKE optional
      !IV_DISPLAY_TYPE type CHAR1 optional
      !IV_USE_GRID type ABAP_BOOL optional
    returning
      value(RO_LOG) type ref to ZCL_API_LOG .
*      !IO_EXCEPTION type ref to ZCX_BC_COMMON optional
  methods ADD_MESSAGE
    importing
      !IS_BAL_MSG type BAL_S_MSG optional
      !IS_SY type SYST default SY
      !IS_SYMSG type SYMSG optional
      !IT_BAPIRET type BAPIRET2_TAB optional
      !IS_BAPIRET type BAPIRET2 optional
      !IT_BATCH type ETTCD_MSG_TABTYPE optional
      !IO_APPL_LOG type ref to ZCL_API_LOG optional
      !IT_ANYMSG type ANY TABLE optional
      !IS_ANYMSG type ANY optional
      !IV_TEXTMSG1 type SYST-MSGV1 optional
      !IV_TEXTMSG2 type SYST-MSGV2 optional
      !IV_TEXTMSG3 type SYST-MSGV3 optional
      !IV_TEXTMSG4 type SYST-MSGV4 optional
      !IV_TEXTMSGTY type SYST-MSGTY default 'I'
      !IV_TEXTMSGID type SYST-MSGID default '01'
      !IV_TEXTMSGNO type SYST-MSGNO default 319 .
  methods SHOW
    importing
      !IV_TITLE type BALTITLE optional
      !IV_DISPLAY_TYPE type CHAR1 default MC_SBAL_PROFILE-SINGLE
      !IO_CONTAINER type ref to CL_GUI_CONTAINER optional
      !IV_POPUP type BOOLEAN default ''
    returning
      value(RV_UCOMM) type SY-UCOMM .
  methods CLEAR .
  methods SAVE
    importing
      !IM_UPD_TASK type BOOLEAN default ABAP_FALSE
      !I_SAVE_ALL type BOOLEAN default ABAP_FALSE
    exporting
      !EX_HANDLER type BALLOGHNDL .
  class-methods LOAD
    importing
      !IS_LOG_FILTER type BAL_S_LFIL optional
      !IV_OBJECT type BALOBJ_D optional
      !IV_SUBOBJECT type BALSUBOBJ optional
      !IV_EXTNUMBER type CLIKE optional
      !IV_INSTANCE_TYPE type CLIKE optional
    returning
      value(RO_LOG) type ref to ZCL_API_LOG .
  methods GET_MESSAGES
    returning
      value(EX_T_MSG) type BAL_T_MSG .
  methods MESSAGE_COUNT
    importing
      !IM_MSG_TYPE type SYMSGTY optional
    returning
      value(RE_COUNT) type I .
  methods HAS_ERRORS
    returning
      value(RE_VALUE) type ABAP_BOOL .
  methods HAS_MESSAGES
    importing
      !IV_MSG_TYPE type SYMSGTY optional
    returning
      value(RE_VALUE) type ABAP_BOOL .
  methods HAS_WARNINGS
    returning
      value(RE_VALUE) type ABAP_BOOL .
  methods REFRESH .
  methods SET_PROFILE
    importing
      !IV_DISPLAY_TYPE type CHAR1 default MC_SBAL_PROFILE-SINGLE
      !IV_TREE_WIDTH type I optional
      !IS_DISPLAY_PARAMETERS type BAL_S_PROF optional
      !IV_USE_GRID type BOOLE_D default SPACE
      !IV_NO_TOOLBAR type BOOLE_D default ABAP_TRUE
      !IV_TITLE type BALTITLE optional .
  methods SHOW_AND_CLEAR
    importing
      !IV_SHOW_ONLY_ERRORS type ABAP_BOOL default ABAP_FALSE
      !IO_SAVE_PROTOCOL type ref to ZCL_API_LOG optional
      !IV_SAVE_HANDLE type ABAP_BOOL default ABAP_FALSE .
protected section.

  data MV_HANDLE type BALLOGHNDL .
  data MS_HEADER type BAL_S_LOG .
  data MS_DISPPR type BAL_S_PROF .
  data MV_DETLEVEL type BALLEVEL .
  data MS_CONTEXT type BAL_S_CONT .
  data MV_COUNT_ERROR type I .
  data MV_COUNT_WARN type I .
  data MV_CONTROL_HANDLE type BALCNTHNDL .
private section.
ENDCLASS.



CLASS ZCL_API_LOG IMPLEMENTATION.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method ZCL_API_LOG->ADD_MESSAGE
* +-------------------------------------------------------------------------------------------------+
* | [--->] IS_BAL_MSG                     TYPE        BAL_S_MSG(optional)
* | [--->] IS_SY                          TYPE        SYST (default =SY)
* | [--->] IS_SYMSG                       TYPE        SYMSG(optional)
* | [--->] IT_BAPIRET                     TYPE        BAPIRET2_TAB(optional)
* | [--->] IS_BAPIRET                     TYPE        BAPIRET2(optional)
* | [--->] IT_BATCH                       TYPE        ETTCD_MSG_TABTYPE(optional)
* | [--->] IO_APPL_LOG                    TYPE REF TO ZCL_API_LOG(optional)
* | [--->] IT_ANYMSG                      TYPE        ANY TABLE(optional)
* | [--->] IS_ANYMSG                      TYPE        ANY(optional)
* | [--->] IV_TEXTMSG1                    TYPE        SYST-MSGV1(optional)
* | [--->] IV_TEXTMSG2                    TYPE        SYST-MSGV2(optional)
* | [--->] IV_TEXTMSG3                    TYPE        SYST-MSGV3(optional)
* | [--->] IV_TEXTMSG4                    TYPE        SYST-MSGV4(optional)
* | [--->] IV_TEXTMSGTY                   TYPE        SYST-MSGTY (default ='I')
* | [--->] IV_TEXTMSGID                   TYPE        SYST-MSGID (default ='01')
* | [--->] IV_TEXTMSGNO                   TYPE        SYST-MSGNO (default =319)
* +--------------------------------------------------------------------------------------</SIGNATURE>
METHOD add_message.

  DATA lt_bal_msg TYPE bal_t_msg.
  DATA ls_bal_msg TYPE bal_s_msg.
  DATA ls_bapiret TYPE bapiret2.
  FIELD-SYMBOLS: <ls_any> TYPE any.


  IF is_bal_msg IS SUPPLIED.
* Добавляем одиночное сообщение в лог

    ls_bal_msg = is_bal_msg.
    ls_bal_msg-detlevel = detlevel.
    ls_bal_msg-probclass = probclass.
    ls_bal_msg-alsort = alsort.
    ls_bal_msg-time_stmp = time_stmp.
    ls_bal_msg-msg_count = msg_count.
    ls_bal_msg-context = context.
    ls_bal_msg-params = params.

    CALL FUNCTION 'BAL_LOG_MSG_ADD'
      EXPORTING
        i_log_handle     = mv_handle
        i_s_msg          = ls_bal_msg
      EXCEPTIONS
        log_not_found    = 1
        msg_inconsistent = 2
        log_is_full      = 3
        OTHERS           = 4.
    CHECK sy-subrc = 0.
  ENDIF.

  IF is_symsg IS SUPPLIED.
    ls_bal_msg-msgty = is_symsg-msgty.
    ls_bal_msg-msgid = is_symsg-msgid.
    ls_bal_msg-msgno = is_symsg-msgno.
    ls_bal_msg-msgv1 = is_symsg-msgv1.
    ls_bal_msg-msgv2 = is_symsg-msgv2.
    ls_bal_msg-msgv3 = is_symsg-msgv3.
    ls_bal_msg-msgv4 = is_symsg-msgv4.
    add_message( is_bal_msg = ls_bal_msg ).
  ENDIF.

  IF it_bapiret IS SUPPLIED.
* Добавляем сообщения в лог из BAPIRET2
    LOOP AT it_bapiret INTO ls_bapiret.
      add_message( is_bapiret = ls_bapiret ).
*      CLEAR ls_bal_msg.
*      ls_bal_msg-msgty = ls_bapiret-type.
*      ls_bal_msg-msgid = ls_bapiret-id.
*      ls_bal_msg-msgno = ls_bapiret-number.
*      ls_bal_msg-msgv1 = ls_bapiret-message_v1.
*      ls_bal_msg-msgv2 = ls_bapiret-message_v2.
*      ls_bal_msg-msgv3 = ls_bapiret-message_v3.
*      ls_bal_msg-msgv4 = ls_bapiret-message_v4.
*      add_message( is_bal_msg = ls_bal_msg ).
    ENDLOOP.
  ENDIF.

  IF is_bapiret IS SUPPLIED.
    CLEAR ls_bal_msg.
    ls_bal_msg-msgty = is_bapiret-type.
    ls_bal_msg-msgid = is_bapiret-id.
    ls_bal_msg-msgno = is_bapiret-number.
    ls_bal_msg-msgv1 = is_bapiret-message_v1.
    ls_bal_msg-msgv2 = is_bapiret-message_v2.
    ls_bal_msg-msgv3 = is_bapiret-message_v3.
    ls_bal_msg-msgv4 = is_bapiret-message_v4.
    add_message( is_bal_msg = ls_bal_msg ).
  ENDIF.

  IF it_batch IS SUPPLIED.
* Добавляем сообщения в лог из пакетного ввода
    LOOP AT it_batch INTO DATA(ls_batch).
      CLEAR ls_bal_msg.
      ls_bal_msg-msgty = ls_batch-msgtyp.
      ls_bal_msg-msgid = ls_batch-msgid.
      ls_bal_msg-msgno = ls_batch-msgnr.
      ls_bal_msg-msgv1 = ls_batch-msgv1.
      ls_bal_msg-msgv2 = ls_batch-msgv2.
      ls_bal_msg-msgv3 = ls_batch-msgv3.
      ls_bal_msg-msgv4 = ls_batch-msgv4.
      add_message( is_bal_msg = ls_bal_msg ).
    ENDLOOP.
  ENDIF.

*  IF io_exception IS SUPPLIED.
*    ls_bal_msg-msgid = io_exception->if_t100_message~t100key-msgid.
*    ls_bal_msg-msgno = io_exception->if_t100_message~t100key-msgno.
*    ls_bal_msg-msgty = io_exception->mv_msgty.
*    ls_bal_msg-msgv1 = io_exception->mv_msgv1.
*    ls_bal_msg-msgv2 = io_exception->mv_msgv2.
*    ls_bal_msg-msgv3 = io_exception->mv_msgv3.
*    ls_bal_msg-msgv4 = io_exception->mv_msgv4.
*    add_message( is_bal_msg = ls_bal_msg ).
*  ENDIF.

  IF io_appl_log IS SUPPLIED.
    lt_bal_msg = io_appl_log->get_messages( ).
    LOOP AT lt_bal_msg INTO ls_bal_msg.
      add_message( is_bal_msg = ls_bal_msg ).
    ENDLOOP.

  ENDIF.

  IF is_sy IS SUPPLIED.
    ls_bal_msg-msgty = is_sy-msgty.
    ls_bal_msg-msgid = is_sy-msgid.
    ls_bal_msg-msgno = is_sy-msgno.
    ls_bal_msg-msgv1 = is_sy-msgv1.
    ls_bal_msg-msgv2 = is_sy-msgv2.
    ls_bal_msg-msgv3 = is_sy-msgv3.
    ls_bal_msg-msgv4 = is_sy-msgv4.
    add_message( is_bal_msg = ls_bal_msg ).

  ENDIF.

  IF is_anymsg IS SUPPLIED.
    CLEAR ls_bal_msg.
    MOVE-CORRESPONDING is_anymsg TO ls_bal_msg.
    IF ls_bal_msg-msgid IS NOT INITIAL AND
       ls_bal_msg-msgno IS NOT INITIAL.
      add_message( is_bal_msg = ls_bal_msg ).
    ELSE.

      CLEAR ls_bapiret.
      MOVE-CORRESPONDING is_anymsg TO ls_bapiret.
      IF ls_bapiret-id IS NOT INITIAL AND
         ls_bapiret-number IS NOT INITIAL.
        add_message( is_bapiret = ls_bapiret ).
      ENDIF.

    ENDIF.
  ENDIF.

  IF it_anymsg IS SUPPLIED.
    LOOP AT it_anymsg ASSIGNING <ls_any>.
      add_message( is_anymsg = <ls_any> ).
*      CLEAR ls_bal_msg.
*      MOVE-CORRESPONDING <ls_any> TO ls_bal_msg.
*      IF ls_bal_msg-msgid IS NOT INITIAL AND
*         ls_bal_msg-msgno IS NOT INITIAL.
*        add_message( is_bal_msg = ls_bal_msg ).
*      ENDIF.
    ENDLOOP.
  ENDIF.

  IF iv_textmsg1 IS NOT INITIAL OR
     iv_textmsg2 IS NOT INITIAL OR
     iv_textmsg3 IS NOT INITIAL OR
     iv_textmsg4 IS NOT INITIAL.

    DATA: ls_syst TYPE syst.

    ls_syst-msgty = sy-msgty.
    ls_syst-msgid = sy-msgid.
    ls_syst-msgno = sy-msgno.
    ls_syst-msgv1 = sy-msgv1.
    ls_syst-msgv2 = sy-msgv2.
    ls_syst-msgv3 = sy-msgv3.
    ls_syst-msgv4 = sy-msgv4.

    MESSAGE ID iv_textmsgid TYPE iv_textmsgty NUMBER iv_textmsgno
          WITH iv_textmsg1 iv_textmsg2 iv_textmsg3 iv_textmsg4 INTO me->new_message.
    me->add_message( ).

    sy-msgty = ls_syst-msgty.
    sy-msgid = ls_syst-msgid.
    sy-msgno = ls_syst-msgno.
    sy-msgv1 = ls_syst-msgv1.
    sy-msgv2 = ls_syst-msgv2.
    sy-msgv3 = ls_syst-msgv3.
    sy-msgv4 = ls_syst-msgv4.

  ENDIF.

  IF
     is_bal_msg IS INITIAL AND
     is_symsg IS INITIAL AND
     it_bapiret IS INITIAL AND
     is_bapiret IS INITIAL AND
     it_batch IS INITIAL AND
*     io_exception IS INITIAL AND
     io_appl_log IS INITIAL AND
     it_anymsg IS INITIAL AND
     is_anymsg IS INITIAL AND

     ( sy-msgno IS NOT INITIAL OR sy-msgid IS NOT INITIAL ) AND
     new_message IS NOT INITIAL.

    CLEAR ls_bal_msg.
    CLEAR new_message.

    ls_bal_msg-msgty = sy-msgty.
    ls_bal_msg-msgid = sy-msgid.
    ls_bal_msg-msgno = sy-msgno.
    ls_bal_msg-msgv1 = sy-msgv1.
    ls_bal_msg-msgv2 = sy-msgv2.
    ls_bal_msg-msgv3 = sy-msgv3.
    ls_bal_msg-msgv4 = sy-msgv4.
    add_message( is_bal_msg = ls_bal_msg ).

  ENDIF.

  RAISE EVENT on_content_changed.

ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method ZCL_API_LOG->CLEAR
* +-------------------------------------------------------------------------------------------------+
* +--------------------------------------------------------------------------------------</SIGNATURE>
METHOD clear.

* Удаляем все сообщения из лога
  CALL FUNCTION 'BAL_LOG_MSG_DELETE_ALL'
    EXPORTING
      i_log_handle  = mv_handle
    EXCEPTIONS
      log_not_found = 1
      OTHERS        = 2.
  IF sy-subrc = 0.
    RAISE EVENT on_content_changed.
  ENDIF.



ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method ZCL_API_LOG->CONSTRUCTOR
* +-------------------------------------------------------------------------------------------------+
* | [--->] IV_HANDLER                     TYPE        BALLOGHNDL
* | [--->] IV_TIMESTAMP                   TYPE        BALTIMSTMP(optional)
* +--------------------------------------------------------------------------------------</SIGNATURE>
METHOD CONSTRUCTOR.

  mv_handle = iv_handler.

  IF iv_timestamp IS NOT INITIAL.
    time_stmp = iv_timestamp.
  ELSE.
    GET TIME STAMP FIELD time_stmp.
  ENDIF.

ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Static Public Method ZCL_API_LOG=>CREATE_LOG
* +-------------------------------------------------------------------------------------------------+
* | [--->] IV_OBJECT                      TYPE        BALOBJ_D(optional)
* | [--->] IV_SUBOBJECT                   TYPE        BALSUBOBJ(optional)
* | [--->] IV_EXTNUMBER                   TYPE        CLIKE(optional)
* | [--->] IV_INSTANCE_TYPE               TYPE        CLIKE(optional)
* | [--->] IV_DISPLAY_TYPE                TYPE        CHAR1(optional)
* | [<-()] RO_LOG                         TYPE REF TO ZCL_API_LOG
* +--------------------------------------------------------------------------------------</SIGNATURE>
METHOD create_log.

  CLEAR ro_log.

* Создаем программный лог для указанного объекта подобъекта
* ЛОКАЛЬНЫЕ ПЕРЕМЕННЫЕ
  DATA lv_log_header TYPE bal_s_log.
  DATA lv_handler    TYPE balloghndl.

* ПРОГРАММА
  lv_log_header-object    = iv_object.
  lv_log_header-subobject = iv_subobject.
  lv_log_header-extnumber = iv_extnumber.
  lv_log_header-aldate    = sy-datum.
  lv_log_header-altime    = sy-uzeit.
  lv_log_header-aluser    = sy-uname.
  lv_log_header-alprog    = sy-repid.

  " create log handler
  CALL FUNCTION 'BAL_LOG_CREATE'
    EXPORTING
      i_s_log                 = lv_log_header
    IMPORTING
      e_log_handle            = lv_handler
    EXCEPTIONS
      log_header_inconsistent = 1
      OTHERS                  = 2.
  CHECK sy-subrc = 0.

  " wrap handle in our object
  IF iv_instance_type IS NOT INITIAL.
    CREATE OBJECT ro_log
      TYPE (iv_instance_type)
      EXPORTING
        iv_handler = lv_handler.
  ELSE.
    CREATE OBJECT ro_log
      EXPORTING
        iv_handler = lv_handler.
  ENDIF.

  IF ro_log IS NOT INITIAL.
    IF iv_display_type IS NOT INITIAL.
      ro_log->set_profile( iv_display_type = iv_display_type
                           iv_use_grid     = iv_use_grid ).
    ENDIF.
  ENDIF.

ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method ZCL_API_LOG->GET_MESSAGES
* +-------------------------------------------------------------------------------------------------+
* | [<-()] EX_T_MSG                       TYPE        BAL_T_MSG
* +--------------------------------------------------------------------------------------</SIGNATURE>
METHOD GET_MESSAGES.

  DATA: t_log_filter  TYPE bal_s_lfil
      , t_handle      TYPE LINE OF bal_s_lfil-log_handle
      , lt_msg_handle  TYPE bal_t_msgh
      , t_msg_handle   TYPE LINE OF bal_t_msgh
      , t_message      LIKE LINE OF ex_t_msg
      .
  CLEAR t_log_filter.
  REFRESH t_log_filter-log_handle.
  CLEAR t_handle.
  t_handle-sign       = 'I'.
  t_handle-option     = 'EQ'.
  t_handle-low        = mv_handle.
  APPEND t_handle TO t_log_filter-log_handle.

*   находим сообщения текущего лога
  REFRESH lt_msg_handle.
  CALL FUNCTION 'BAL_GLB_SEARCH_MSG'
    EXPORTING
      i_s_log_filter = t_log_filter
    IMPORTING
*     E_T_LOG_HANDLE =
      e_t_msg_handle = lt_msg_handle
    EXCEPTIONS
      msg_not_found  = 1
      OTHERS         = 2.
   check sy-subrc = 0.

  REFRESH EX_T_MSG  .
*   читаем все найденные сообщения
  LOOP AT lt_msg_handle INTO t_msg_handle.
    CALL FUNCTION 'BAL_LOG_MSG_READ'
      EXPORTING
        i_s_msg_handle = t_msg_handle
      IMPORTING
        e_s_msg        = t_message
      EXCEPTIONS
        log_not_found  = 1
        msg_not_found  = 2
        OTHERS         = 3.
     check sy-subrc = 0.

    APPEND t_message TO EX_T_MSG.
  ENDLOOP.
ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method ZCL_API_LOG->HAS_ERRORS
* +-------------------------------------------------------------------------------------------------+
* | [<-()] RE_VALUE                       TYPE        ABAP_BOOL
* +--------------------------------------------------------------------------------------</SIGNATURE>
METHOD HAS_ERRORS.

  re_value = 'X'.

  CHECK message_count( 'E' ) IS INITIAL.
  CHECK message_count( 'A' ) IS INITIAL.

  CLEAR re_value.

ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method ZCL_API_LOG->HAS_MESSAGES
* +-------------------------------------------------------------------------------------------------+
* | [--->] IV_MSG_TYPE                    TYPE        SYMSGTY(optional)
* | [<-()] RE_VALUE                       TYPE        ABAP_BOOL
* +--------------------------------------------------------------------------------------</SIGNATURE>
METHOD HAS_MESSAGES.

  re_value = 'X'.

  CHECK message_count( iv_msg_type ) IS INITIAL.

  CLEAR re_value.

ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method ZCL_API_LOG->HAS_WARNINGS
* +-------------------------------------------------------------------------------------------------+
* | [<-()] RE_VALUE                       TYPE        ABAP_BOOL
* +--------------------------------------------------------------------------------------</SIGNATURE>
METHOD HAS_WARNINGS.

  re_value = 'X'.

  CHECK message_count( 'W' ) IS INITIAL.

  CLEAR re_value.

ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Static Public Method ZCL_API_LOG=>LOAD
* +-------------------------------------------------------------------------------------------------+
* | [--->] IS_LOG_FILTER                  TYPE        BAL_S_LFIL(optional)
* | [--->] IV_OBJECT                      TYPE        BALOBJ_D(optional)
* | [--->] IV_SUBOBJECT                   TYPE        BALSUBOBJ(optional)
* | [--->] IV_EXTNUMBER                   TYPE        CLIKE(optional)
* | [--->] IV_INSTANCE_TYPE               TYPE        CLIKE(optional)
* | [<-()] RO_LOG                         TYPE REF TO ZCL_API_LOG
* +--------------------------------------------------------------------------------------</SIGNATURE>
METHOD load.

  CLEAR ro_log.

  DATA: lt_log_header TYPE balhdr_t,
        lt_log_handle TYPE bal_t_logh,
        lt_hdr_tmp    TYPE balhdr_t,
        ls_log_filter TYPE bal_s_lfil.

  FIELD-SYMBOLS: <ls_log_header> LIKE LINE OF lt_log_header,
                 <ls_log_handle> LIKE LINE OF lt_log_handle.
  FIELD-SYMBOLS <ls_object> LIKE LINE OF ls_log_filter-object.
  FIELD-SYMBOLS <ls_subobject> LIKE LINE OF ls_log_filter-subobject.
  FIELD-SYMBOLS <ls_extnumber> LIKE LINE OF ls_log_filter-extnumber.

  IF iv_object IS SUPPLIED.
    INSERT INITIAL LINE INTO TABLE ls_log_filter-object ASSIGNING <ls_object>.
    <ls_object>-sign = 'I'.
    <ls_object>-option = 'EQ'.
    <ls_object>-low = iv_object.

    INSERT INITIAL LINE INTO TABLE ls_log_filter-subobject ASSIGNING <ls_subobject>.
    <ls_subobject>-sign = 'I'.
    <ls_subobject>-option = 'EQ'.
    <ls_subobject>-low = iv_subobject.

    INSERT INITIAL LINE INTO TABLE ls_log_filter-extnumber ASSIGNING <ls_extnumber>.
    <ls_extnumber>-sign = 'I'.
    <ls_extnumber>-option = 'EQ'.
    <ls_extnumber>-low = iv_extnumber.

  ELSE.
    ls_log_filter = is_log_filter.
  ENDIF.

  CHECK ls_log_filter IS NOT INITIAL AND
        ( ls_log_filter-object IS NOT INITIAL OR
          ls_log_filter-subobject IS NOT INITIAL OR
          ls_log_filter-extnumber IS NOT INITIAL ).

*   search on DB for these logs
  CALL FUNCTION 'BAL_DB_SEARCH'
    EXPORTING
      i_s_log_filter     = ls_log_filter
    IMPORTING
      e_t_log_header     = lt_log_header
    EXCEPTIONS
      log_not_found      = 1
      no_filter_criteria = 2
      OTHERS             = 3.
  CHECK sy-subrc = 0.

  lt_hdr_tmp = lt_log_header.
  REFRESH lt_log_header.
  READ TABLE lt_hdr_tmp ASSIGNING <ls_log_header> INDEX lines( lt_hdr_tmp ).
  IF sy-subrc = 0.
    APPEND <ls_log_header> TO lt_log_header.
  ENDIF.

  CALL FUNCTION 'BAL_DB_LOAD'
    EXPORTING
      i_t_log_header                = lt_log_header
      i_exception_if_already_loaded = abap_true
    IMPORTING
      e_t_log_handle                = lt_log_handle
    EXCEPTIONS
      no_logs_specified             = 1
      log_not_found                 = 2
      log_already_loaded            = 3
      OTHERS                        = 4.
  IF sy-subrc = 3.

    LOOP AT lt_log_header INTO DATA(ls_log_header) WHERE log_handle IS NOT INITIAL.
      INSERT ls_log_header-log_handle INTO TABLE lt_log_handle.
    ENDLOOP.

    CALL FUNCTION 'BAL_DB_RELOAD'
      EXPORTING
        i_t_log_handle    = lt_log_handle
      EXCEPTIONS
        no_logs_specified = 1
        log_not_found     = 2
        OTHERS            = 3.
    IF sy-subrc <> 0.
      EXIT.
    ENDIF.

  ELSEIF sy-subrc <> 0.
    EXIT.
  ENDIF.

  CALL FUNCTION 'BAL_GLB_SEARCH_MSG'
    EXPORTING
      i_s_log_filter = ls_log_filter
    EXCEPTIONS
      msg_not_found  = 0
      OTHERS         = 0.

  READ TABLE lt_log_header ASSIGNING <ls_log_header> INDEX 1.
  CHECK sy-subrc = 0.
  READ TABLE lt_log_handle ASSIGNING <ls_log_handle> INDEX 1.
  CHECK sy-subrc = 0.

  IF iv_instance_type IS NOT INITIAL.
    CREATE OBJECT ro_log
      TYPE (iv_instance_type)
      EXPORTING
        iv_handler = <ls_log_handle>.
  ELSE.
    CREATE OBJECT ro_log
      EXPORTING
        iv_handler = <ls_log_handle>.
  ENDIF.

ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method ZCL_API_LOG->MESSAGE_COUNT
* +-------------------------------------------------------------------------------------------------+
* | [--->] IM_MSG_TYPE                    TYPE        SYMSGTY(optional)
* | [<-()] RE_COUNT                       TYPE        I
* +--------------------------------------------------------------------------------------</SIGNATURE>
METHOD MESSAGE_COUNT.

  DATA:
       l_it_handles    TYPE bal_t_logh
       ,l_it_messages  TYPE bal_t_msgh
       ,ls_msg_filter  TYPE bal_s_mfil
       ,ls_msg_type    TYPE bal_s_msty
       .


* установка параметров вызова
  REFRESH l_it_handles.
  APPEND mv_handle TO l_it_handles.

  IF NOT im_msg_type IS INITIAL.
    CLEAR ls_msg_filter.
    ls_msg_type-sign   = 'I'.
    ls_msg_type-option = 'EQ'.
    ls_msg_type-low    = im_msg_type.
    APPEND ls_msg_type TO ls_msg_filter-msgty.
  ENDIF.
* вызов стандартного ФМ (подсчет числа сообщений)
  CALL FUNCTION 'BAL_GLB_SEARCH_MSG'
    EXPORTING
      i_t_log_handle = l_it_handles
      i_s_msg_filter = ls_msg_filter
    IMPORTING
      e_t_msg_handle = l_it_messages
    EXCEPTIONS
      msg_not_found  = 1
      OTHERS         = 2.

  IF sy-subrc = 0.
    DESCRIBE TABLE l_it_messages LINES re_count.
  ENDIF.
ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method ZCL_API_LOG->REFRESH
* +-------------------------------------------------------------------------------------------------+
* +--------------------------------------------------------------------------------------</SIGNATURE>
METHOD refresh.

  DATA lt_handle TYPE bal_t_logh.
  REFRESH lt_handle.
  INSERT mv_handle INTO TABLE lt_handle.

  CALL FUNCTION 'BAL_CNTL_REFRESH'
    EXPORTING
      i_control_handle  = mv_control_handle
      i_t_log_handle    = lt_handle
    EXCEPTIONS
      control_not_found = 1
      internal_error    = 2
      OTHERS            = 3.
   check sy-subrc = 0.

ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method ZCL_API_LOG->SAVE
* +-------------------------------------------------------------------------------------------------+
* | [--->] IM_UPD_TASK                    TYPE        BOOLEAN (default =ABAP_FALSE)
* | [--->] I_SAVE_ALL                     TYPE        BOOLEAN (default =ABAP_FALSE)
* | [<---] EX_HANDLER                     TYPE        BALLOGHNDL
* +--------------------------------------------------------------------------------------</SIGNATURE>
METHOD SAVE.

  DATA lt_handler TYPE bal_t_logh.
  DATA ls_handler TYPE LINE OF bal_t_logh.

  MOVE mv_handle TO ls_handler.
  INSERT ls_handler INTO TABLE lt_handler.

  CALL FUNCTION 'BAL_DB_SAVE'
    EXPORTING
      i_in_update_task = im_upd_task
      i_save_all       = i_save_all
      i_t_log_handle   = lt_handler[]
    EXCEPTIONS
      log_not_found    = 1
      save_not_allowed = 2
      numbering_error  = 3
      OTHERS           = 4.

ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method ZCL_API_LOG->SET_PROFILE
* +-------------------------------------------------------------------------------------------------+
* | [--->] IV_DISPLAY_TYPE                TYPE        CHAR1 (default =MC_SBAL_PROFILE-SINGLE)
* | [--->] IV_TREE_WIDTH                  TYPE        I(optional)
* | [--->] IS_DISPLAY_PARAMETERS          TYPE        BAL_S_PROF(optional)
* | [--->] IV_USE_GRID                    TYPE        BOOLE_D (default =SPACE)
* | [--->] IV_NO_TOOLBAR                  TYPE        BOOLE_D (default =ABAP_TRUE)
* | [--->] IV_TITLE                       TYPE        BALTITLE(optional)
* +--------------------------------------------------------------------------------------</SIGNATURE>
METHOD SET_PROFILE.

  IF is_display_parameters IS NOT INITIAL.
    ms_disppr = is_display_parameters.
  ENDIF.

  CASE iv_display_type.
    WHEN mc_sbal_profile-single.
      CALL FUNCTION 'BAL_DSP_PROFILE_SINGLE_LOG_GET'
        IMPORTING
          e_s_display_profile = ms_disppr.

      ms_disppr-disvariant-handle = 'LOG'.

    WHEN mc_sbal_profile-detlevel.
*       get variant which creates hierarchy according to field DETLEVEL
      CALL FUNCTION 'BAL_DSP_PROFILE_DETLEVEL_GET'
        IMPORTING
          e_s_display_profile = ms_disppr.

*       set report to allow saving of variants
      ms_disppr-tree_ontop = space.
      ms_disppr-tree_size  = iv_tree_width.

    WHEN mc_sbal_profile-popup.
      CALL FUNCTION 'BAL_DSP_PROFILE_POPUP_GET'
       EXPORTING
         START_COL                 = ms_disppr-start_col
         START_ROW                 = ms_disppr-start_row
         END_COL                   = ms_disppr-end_col
         END_ROW                   = ms_disppr-end_row
       IMPORTING
         e_s_display_profile = ms_disppr.

    WHEN mc_sbal_profile-no_tree.
      CALL FUNCTION 'BAL_DSP_PROFILE_NO_TREE_GET'
        IMPORTING
          e_s_display_profile = ms_disppr.

  ENDCASE.

  IF iv_title IS NOT INITIAL.
    ms_disppr-title = iv_title.
  ENDIF.
  IF iv_tree_width IS NOT INITIAL.
    ms_disppr-tree_size = iv_tree_width.
  ENDIF.

  ms_disppr-use_grid = iv_use_grid.
  ms_disppr-no_toolbar = iv_no_toolbar.
  ms_disppr-disvariant-report = sy-repid.
*  ms_disppr-tree_nomsg = 'X'.

ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method ZCL_API_LOG->SHOW
* +-------------------------------------------------------------------------------------------------+
* | [--->] IV_TITLE                       TYPE        BALTITLE(optional)
* | [--->] IV_DISPLAY_TYPE                TYPE        CHAR1 (default =MC_SBAL_PROFILE-SINGLE)
* | [--->] IO_CONTAINER                   TYPE REF TO CL_GUI_CONTAINER(optional)
* | [--->] IV_POPUP                       TYPE        BOOLEAN (default ='')
* | [<-()] RV_UCOMM                       TYPE        SY-UCOMM
* +--------------------------------------------------------------------------------------</SIGNATURE>
METHOD show.

  IF ms_disppr IS INITIAL AND iv_display_type IS SUPPLIED.
    set_profile( iv_display_type = iv_display_type ).
  ENDIF.

  IF iv_title IS NOT INITIAL.
    ms_disppr-title = iv_title.
  ENDIF.

  DATA lt_handle TYPE bal_t_logh.
  REFRESH lt_handle.
  INSERT mv_handle INTO TABLE lt_handle.

  DATA(lv_old_ucomm) = sy-ucomm.

  IF io_container IS BOUND.
    CALL FUNCTION 'BAL_CNTL_CREATE'
      EXPORTING
        i_container          = io_container
        i_s_display_profile  = ms_disppr
        i_t_log_handle       = lt_handle
      IMPORTING
        e_control_handle     = mv_control_handle
      EXCEPTIONS
        profile_inconsistent = 1
        internal_error       = 2
        OTHERS               = 3.
    CHECK sy-subrc = 0.

  ELSE.
*    IF iv_popup IS NOT INITIAL.
*      ms_disppr-start_col = i_left.
*      ms_disppr-start_row = i_top.
*      ms_disppr-end_col   = i_left + i_width.
*      ms_disppr-end_row   = i_top  + i_height.
*      ms_disppr-pop_adjst = i_adjust.
*    ENDIF.

    CALL FUNCTION 'BAL_DSP_LOG_DISPLAY'
      EXPORTING
        i_t_log_handle       = lt_handle
        i_amodal             = iv_popup
        i_s_display_profile  = ms_disppr
      EXCEPTIONS
        profile_inconsistent = 1
        internal_error       = 2
        no_data_available    = 3
        no_authority         = 4.
  ENDIF.
  CHECK sy-subrc = 0.

  rv_ucomm = sy-ucomm.
  sy-ucomm = lv_old_ucomm.

ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method ZCL_API_LOG->SHOW_AND_CLEAR
* +-------------------------------------------------------------------------------------------------+
* | [--->] IV_SHOW_ONLY_ERRORS            TYPE        ABAP_BOOL (default =ABAP_FALSE)
* | [--->] IO_SAVE_PROTOCOL               TYPE REF TO ZCL_API_LOG(optional)
* | [--->] IV_SAVE_HANDLE                 TYPE        ABAP_BOOL (default =ABAP_FALSE)
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD show_and_clear.

    IF abap_true = me->has_messages( ).

      IF io_save_protocol IS NOT INITIAL.
        io_save_protocol->clear( ).
        io_save_protocol->add_message( io_appl_log = me ).
      ENDIF.

      IF iv_save_handle = abap_true.
        me->save( ).
      ENDIF.

      IF me->message_count( ) = 1. " Show 1 msg in status bar
        DATA: lt_msg TYPE bal_t_msg,
              ls_msg TYPE LINE OF bal_t_msg.
        lt_msg = me->get_messages( ).
        READ TABLE lt_msg INTO ls_msg INDEX 1.
        MESSAGE ID ls_msg-msgid TYPE 'S' NUMBER ls_msg-msgno
          WITH ls_msg-msgv1 ls_msg-msgv2 ls_msg-msgv3 ls_msg-msgv4 DISPLAY LIKE ls_msg-msgty.

      ELSEIF abap_true = me->has_errors( ). " Always show errors
        me->show( ).

      ELSEIF iv_show_only_errors = abap_false. " Show others only if flag set
        me->show( ).

      ENDIF.

      me->clear( ).

    ENDIF.


  ENDMETHOD.
ENDCLASS.
