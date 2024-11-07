PROGRAM TUI_EDITOR
    IMPLICIT NONE
    CHARACTER(LEN=255) :: FILENAME, LINE
    INTEGER :: I, FILE_UNIT, CURRENT_LINE = 1
    LOGICAL :: EDITING = .TRUE.
    TYPE(BUFFER_LINE), POINTER :: BUFFER_HEAD => NULL(), CURRENT_LINE_PTR => NULL()

    PRINT *, 'Advanced TUI Editor for MS-DOS'
    PRINT *, 'Enter the filename to edit (or "new" for a new file):'
    READ(*, '(A)') FILENAME

    IF (FILENAME == 'new') THEN
        CALL EDIT_NEW_FILE
    ELSE
        CALL EDIT_EXISTING_FILE(FILENAME)
    END IF

CONTAINS

    SUBROUTINE EDIT_NEW_FILE
        CHARACTER(LEN=255) :: LINE
        INTEGER :: I

        PRINT *, 'Editing new file. Type "SAVE filename" to save and exit, or "EXIT" to exit without saving.'

        DO WHILE (EDITING)
            PRINT *, 'Enter a line (or "SAVE filename" to save and exit, or "EXIT" to exit without saving):'
            READ(*, '(A)') LINE

            IF (LINE(1:4) == 'SAVE') THEN
                CALL SAVE_FILE(LINE(6:))
                EDITING = .FALSE.
            ELSE IF (LINE == 'EXIT') THEN
                EDITING = .FALSE.
            ELSE
                CALL APPEND_LINE_TO_BUFFER(LINE)
            END IF
        END DO
    END SUBROUTINE EDIT_NEW_FILE

    SUBROUTINE EDIT_EXISTING_FILE(FILENAME)
        CHARACTER(LEN=255), INTENT(IN) :: FILENAME
        CHARACTER(LEN=255) :: LINE
        INTEGER :: FILE_UNIT, IOS

        PRINT *, 'Opening file: ', FILENAME
        OPEN(UNIT=FILE_UNIT, FILE=FILENAME, STATUS='OLD', ACTION='READ', IOSTAT=IOS)

        IF (IOS /= 0) THEN
            PRINT *, 'Error opening file: ', FILENAME
            RETURN
        END IF

        PRINT *, 'File content:'
        DO
            READ(FILE_UNIT, '(A)', IOSTAT=IOS) LINE
            IF (IOS /= 0) EXIT
            PRINT *, LINE
            CALL APPEND_LINE_TO_BUFFER(LINE)
        END DO

        CLOSE(FILE_UNIT)

        CURRENT_LINE_PTR => BUFFER_HEAD

        PRINT *, 'Editing file. Type "SAVE" to save and exit, or "EXIT" to exit without saving.'
        PRINT *, 'Use "UP" and "DOWN" to navigate, "INSERT" to insert a line, and "DELETE" to delete the current line.'

        DO WHILE (EDITING)
            PRINT *, 'Current line: ', CURRENT_LINE, ' -> ', TRIM(CURRENT_LINE_PTR%LINE)
            PRINT *, 'Enter a command (or "SAVE" to save and exit, or "EXIT" to exit without saving):'
            READ(*, '(A)') LINE

            SELECT CASE (LINE)
                CASE ('SAVE')
                    CALL SAVE_FILE(FILENAME)
                    EDITING = .FALSE.
                CASE ('EXIT')
                    EDITING = .FALSE.
                CASE ('UP')
                    CALL MOVE_UP
                CASE ('DOWN')
                    CALL MOVE_DOWN
                CASE ('INSERT')
                    PRINT *, 'Enter the line to insert:'
                    READ(*, '(A)') LINE
                    CALL INSERT_LINE(LINE)
                CASE ('DELETE')
                    CALL DELETE_LINE
                CASE DEFAULT
                    PRINT *, 'Unknown command.'
            END SELECT
        END DO
    END SUBROUTINE EDIT_EXISTING_FILE

    SUBROUTINE SAVE_FILE(FILENAME)
        CHARACTER(LEN=255), INTENT(IN) :: FILENAME
        INTEGER :: FILE_UNIT
        TYPE(BUFFER_LINE), POINTER :: CURRENT_LINE_PTR

        PRINT *, 'Saving file: ', FILENAME
        OPEN(UNIT=FILE_UNIT, FILE=FILENAME, STATUS='REPLACE', ACTION='WRITE')

        CURRENT_LINE_PTR => BUFFER_HEAD
        DO WHILE (ASSOCIATED(CURRENT_LINE_PTR))
            WRITE(FILE_UNIT, '(A)') TRIM(CURRENT_LINE_PTR%LINE)
            CURRENT_LINE_PTR => CURRENT_LINE_PTR%NEXT
        END DO

        CLOSE(FILE_UNIT)
        PRINT *, 'File saved successfully.'
    END SUBROUTINE SAVE_FILE

    SUBROUTINE APPEND_LINE_TO_BUFFER(LINE)
        CHARACTER(LEN=255), INTENT(IN) :: LINE
        TYPE(BUFFER_LINE), POINTER :: NEW_LINE, CURRENT_LINE_PTR

        ALLOCATE(NEW_LINE)
        NEW_LINE%LINE = LINE
        NEW_LINE%NEXT => NULL()

        IF (.NOT. ASSOCIATED(BUFFER_HEAD)) THEN
            BUFFER_HEAD => NEW_LINE
        ELSE
            CURRENT_LINE_PTR => BUFFER_HEAD
            DO WHILE (ASSOCIATED(CURRENT_LINE_PTR%NEXT))
                CURRENT_LINE_PTR => CURRENT_LINE_PTR%NEXT
            END DO
            CURRENT_LINE_PTR%NEXT => NEW_LINE
        END IF
    END SUBROUTINE APPEND_LINE_TO_BUFFER

    SUBROUTINE MOVE_UP
        IF (CURRENT_LINE > 1) THEN
            CURRENT_LINE = CURRENT_LINE - 1
            CURRENT_LINE_PTR => CURRENT_LINE_PTR%PREV
        END IF
    END SUBROUTINE MOVE_UP

    SUBROUTINE MOVE_DOWN
        IF (ASSOCIATED(CURRENT_LINE_PTR%NEXT)) THEN
            CURRENT_LINE = CURRENT_LINE + 1
            CURRENT_LINE_PTR => CURRENT_LINE_PTR%NEXT
        END IF
    END SUBROUTINE MOVE_DOWN

    SUBROUTINE INSERT_LINE(LINE)
        TYPE(BUFFER_LINE), POINTER :: NEW_LINE

        ALLOCATE(NEW_LINE)
        NEW_LINE%LINE = LINE
        NEW_LINE%PREV => CURRENT_LINE_PTR%PREV
        NEW_LINE%NEXT => CURRENT_LINE_PTR

        IF (ASSOCIATED(CURRENT_LINE_PTR%PREV)) THEN
            CURRENT_LINE_PTR%PREV%NEXT => NEW_LINE
        ELSE
            BUFFER_HEAD => NEW_LINE
        END IF

        CURRENT_LINE_PTR%PREV => NEW_LINE
        CURRENT_LINE = CURRENT_LINE + 1
    END SUBROUTINE INSERT_LINE

    SUBROUTINE DELETE_LINE
        TYPE(BUFFER_LINE), POINTER :: TEMP_LINE

        IF (ASSOCIATED(CURRENT_LINE_PTR%PREV)) THEN
            CURRENT_LINE_PTR%PREV%NEXT => CURRENT_LINE_PTR%NEXT
        ELSE
            BUFFER_HEAD => CURRENT_LINE_PTR%NEXT
        END IF

        IF (ASSOCIATED(CURRENT_LINE_PTR%NEXT)) THEN
            CURRENT_LINE_PTR%NEXT%PREV => CURRENT_LINE_PTR%PREV
            TEMP_LINE => CURRENT_LINE_PTR%NEXT
        ELSE
            TEMP_LINE => CURRENT_LINE_PTR%PREV
        END IF

        DEALLOCATE(CURRENT_LINE_PTR)
        CURRENT_LINE_PTR => TEMP_LINE
    END SUBROUTINE DELETE_LINE

    TYPE BUFFER_LINE
        CHARACTER(LEN=255) :: LINE
        TYPE(BUFFER_LINE), POINTER :: PREV, NEXT
    END TYPE BUFFER_LINE

END PROGRAM TUI_EDITOR