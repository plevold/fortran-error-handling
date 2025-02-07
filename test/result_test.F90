module result_test
    use iso_fortran_env, only: dp => real64
    use error_handling_experimental_result, only: &
        result_real_dp_rank1_t, &
        result_chars_t
    use error_handling, only: error_stop, error_t
    implicit none

    private
    public test_result


contains
    subroutine test_result
        write(*,*) 'test_result...'
        call ok_func_result_should_be_ok
        call err_func_result_should_give_error
        call result_chars_should_store_chars
        write(*,*) 'test_result [Ok]'
    end subroutine


    subroutine ok_func_result_should_be_ok
        type(result_real_dp_rank1_t) :: y

        y = func(12.0_dp)
        if (y%is_error()) call error_stop('expected value')
        if (.not. y%is_value()) call error_stop('expected value')
    end subroutine


    subroutine err_func_result_should_give_error
        type(result_real_dp_rank1_t) :: y
        character(len=:), allocatable :: chars

        y = func(-12.0_dp)
        if (.not. y%is_error()) call error_stop('expected error')
        if (y%is_value()) call error_stop('expected error')

        chars = y%error%display()
        if (index(chars, 'Error: x must be positive') /= 1) &
            call error_stop('Expected error message in: ' // new_line('c') // chars)
    end subroutine


    subroutine result_chars_should_store_chars
        type(result_chars_t) :: r

        r = 'Hello world'
        if (.not. r%is_value()) call error_stop('expected ok')
        if (.not. r%value == 'Hello world') call error_stop('Unexpected value: ' // r%value)
    end subroutine


    type(result_real_dp_rank1_t) pure function func(x) result(y)
        real(dp), intent(in)  :: x

        if (x >= 0) then
            y = x * [1.0, 2.0, 3.0]
        else
#           ifdef __GFORTRAN__
                ! If we use the assignment operator with gfortran it will
                ! attempt to finalize error_t twice! Compiler bug?
                y%error = error_t('x must be positive')
#           else
                y = error_t('x must be positive')
#           endif
        end if
    end function


end module