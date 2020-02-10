program shapemaker

    ! Here is where we declared variables that this shapemaker
    ! will use. 
   
    real :: r, t, A, C, B, DS
    integer :: x,y,z,idx, x_thick, y_length, z_width, y_offset, z_offset, rastery, rasterz
    character(len=200)::row

    ! Parameters
    
    DS = 2
    idx = 0
    r  = 4
    t = 4
    rastery = 0
    rasterz = 0

    ! Here we open a temporary file, that will be deleted later. 
    ! This is my rigged way of getting around allocating the size
    ! of an array for our shape
    open(12, file='temp3',status='replace')

    y_gap = 20/DS
    z_gap = 20/DS

    ! This loops over our grid
    ! third particle dimensions and location
    x_thick = 40
    y_length  = 200
    z_width = 40
    ! location defined by its centroid. define below vars such that (y_offset, z_offset) as the centroid
    y_offset = 0 + rastery
    z_offset = z_width/2/DS + z_gap/2 + rasterz
    ! calculate parameters
    A = x_thick/(2*DS)+1
    B = y_length/(2*DS)+1
    C = z_width/(2*DS)+1

    do x = -x_thick/2, x_thick/2
       do y = -y_length/2,y_length/2
          do z = -z_width/2, z_width/2
             if ( (ABS((x/A))**r + ABS((y/B))**r)**(t/r) + ABS((z/C))**t  < 1 ) then
                idx = idx+1
                write(12,*) idx , INT(x-A) , INT(y+y_offset) , INT(z+z_offset) ,1,1,1
             end if
          end do
       end do
    end do

    ! This closes the temporary file
    close(12)

    ! We now reopen the file
    open(12, file='temp3',status='old')
    ! We now create our shape file
    open(13, file='shape.dat',status='replace')
    
    ! And write the header of the file
     write(13,*) 'Sphere shape'
     write(13,*) idx, '= number of dipoles in target'
     write(13,*) '1.000000 0.000000 0.000000 = A_1 vector'
     write(13,*) '0.000000 1.000000 0.000000 = A_2 vector'
     write(13,*) '1.000000 1.000000 1.000000 = (d_x,d_y,d_z)/d'
     write(13,*) '0.000000 0.000000 0.000000 = (x,y,z)/d'
     write(13,*) 'JA  IX  IY  IZ ICOMP(x,y,z)'

! And here we read the information of the temporary file, and 
! rewrite it after the header.
do x = 1,idx
   read(12,'(a)') row 
   write(13,'(a)') trim(row)
end do

!Here we delete the temporary file and close the shape file.
close(12,status='delete')
close(13)
end program shapemaker
