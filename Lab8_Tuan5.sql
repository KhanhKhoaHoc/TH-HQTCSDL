--C�u 1
CREATE PROCEDURE lab8_c1
    @manv INT,
    @tennv NVARCHAR(50),
    @gioitinh NVARCHAR(10),
    @diachi NVARCHAR(100),
    @sodt NVARCHAR(20),
    @email NVARCHAR(50),
    @phong NVARCHAR(50),
    @Flag INT
AS
BEGIN
    IF @gioitinh NOT IN ('Nam', N'N?')
    BEGIN
        RETURN 1; -- Tr? v? m� l?i 1 n?u gi?i t�nh kh�ng h?p l?
    END

    IF @Flag = 0
    BEGIN
        INSERT INTO Nhanvien (manv, tennv, gioitinh, diachi, sodt, email, phong)
        VALUES (@manv, @tennv, @gioitinh, @diachi, @sodt, @email, @phong);
    END
    ELSE
    BEGIN
        UPDATE Nhanvien
        SET tennv = @tennv,
            gioitinh = @gioitinh,
            diachi = @diachi,
            sodt = @sodt,
            email = @email,
            phong = @phong
        WHERE manv = @manv;
    END

    RETURN 0; -- Tr? v? m� l?i 0 n?u th�m m?i ho?c c?p nh?t th�nh c�ng
END

--C�u 2
CREATE PROCEDURE lab8_c2
    @masp INT,
    @tenhang NVARCHAR(50),
    @tensp NVARCHAR(50),
    @soluong INT,
    @mausac NVARCHAR(20),
    @giaban FLOAT,
    @donvitinh NVARCHAR(10),
    @mota NVARCHAR(100),
    @Flag INT
AS
BEGIN
    DECLARE @mahangsx INT

    -- Ki?m tra n?u tenhang kh�ng c� trong b?ng hangsx th� tr? v? m� l?i 1
    SELECT @mahangsx = mahangsx FROM Hangsx WHERE tenhang = @tenhang
    IF @mahangsx IS NULL
    BEGIN
        SELECT 1 AS [ErrorCode]
        RETURN
    END

    -- Ki?m tra n?u s? l??ng s?n ph?m l� s? �m th� tr? v? m� l?i 2
    IF @soluong < 0
    BEGIN
        SELECT 2 AS [ErrorCode]
        RETURN
    END

    -- Th�m m?i s?n ph?m
    IF @Flag = 0
    BEGIN
        INSERT INTO Sanpham (masp, mahangsx, tensp, soluong, mausac, giaban, donvitinh, mota)
        VALUES (@masp, @mahangsx, @tensp, @soluong, @mausac, @giaban, @donvitinh, @mota)
    END
    -- C?p nh?t s?n ph?m
    ELSE
    BEGIN
        UPDATE Sanpham 
        SET mahangsx = @mahangsx, tensp = @tensp, soluong = @soluong, mausac = @mausac, giaban = @giaban, 
            donvitinh = @donvitinh, mota = @mota 
        WHERE masp = @masp
    END

    -- Tr? v? m� l?i 0 n?u kh�ng c� l?i
    SELECT 0 AS [ErrorCode]
END

--C�u 3
CREATE PROCEDURE lab8_c3 @manv varchar(10)
AS
BEGIN
    -- Ki?m tra xem manv c� t?n t?i trong b?ng Nhanvien hay kh�ng
    IF NOT EXISTS (SELECT * FROM Nhanvien WHERE manv = @manv)
    BEGIN
        -- Tr? v? m� l?i 1 n?u manv kh�ng t?n t?i
        RETURN 1
    END

    BEGIN TRANSACTION

    BEGIN TRY
        -- X�a c�c b?n ghi trong b?ng Nhap c� m� nh�n vi�n l� manv
        DELETE FROM Nhap WHERE manv = @manv

        -- X�a c�c b?n ghi trong b?ng Xuat c� m� nh�n vi�n l� manv
        DELETE FROM Xuat WHERE manv = @manv

        -- X�a b?n ghi trong b?ng Nhanvien c� m� nh�n vi�n l� manv
        DELETE FROM Nhanvien WHERE manv = @manv

        COMMIT TRANSACTION
    END TRY
    BEGIN CATCH
        -- N?u x?y ra l?i, rollback transaction v� tr? v? m� l?i 2
        ROLLBACK TRANSACTION
        RETURN 2
    END CATCH

    -- Tr? v? m� l?i 0 khi x�a th�nh c�ng
    RETURN 0
END

--C�u 4
CREATE PROCEDURE lab8_c4(@masp VARCHAR(10))
AS
BEGIN

    IF NOT EXISTS (SELECT * FROM sanpham WHERE masp = @masp)
    BEGIN
        SELECT 1 AS 'ErrorCode'
        RETURN
    END
    
    DELETE FROM Nhap WHERE masp = @masp
    
    DELETE FROM Xuat WHERE masp = @masp
    
    DELETE FROM sanpham WHERE masp = @masp
    
    SELECT 0 AS 'ErrorCode'
END

--C�u 5
CREATE PROCEDURE lab8_c5
    @mahangsx varchar(10),
    @tenhang nvarchar(50),
    @diachi nvarchar(100),
    @sodt varchar(20),
    @email varchar(50)
AS
BEGIN
    IF EXISTS (SELECT * FROM Hangsx WHERE tenhang = @tenhang)
    BEGIN
        SELECT 1 AS [ErrorCode]
        RETURN
    END
    INSERT INTO Hangsx (mahangsx, tenhang, diachi, sodt, email)
    VALUES (@mahangsx, @tenhang, @diachi, @sodt, @email)
    SELECT 0 AS [ErrorCode]
    RETURN
END

--C�u 6
CREATE PROCEDURE lab8_c6
    @sohdn nvarchar(50),
    @masp nvarchar(50),
    @manv nvarchar(50),
    @ngaynhap date,
    @soluongN int,
    @dongiaN float
AS
BEGIN
    -- Ki?m tra xem masp c� t?n t?i trong b?ng Sanpham hay kh�ng
    IF NOT EXISTS (SELECT * FROM Sanpham WHERE masp = @masp)
    BEGIN
        -- N?u kh�ng, tr? v? m� l?i 1
        SELECT 1 AS ErrorCode, 'M� s?n ph?m kh�ng t?n t?i' AS ErrorMessage
        RETURN
    END
    
    -- Ki?m tra xem manv c� t?n t?i trong b?ng Nhanvien hay kh�ng
    IF NOT EXISTS (SELECT * FROM Nhanvien WHERE manv = @manv)
    BEGIN
        -- N?u kh�ng, tr? v? m� l?i 2
        SELECT 2 AS ErrorCode, 'M� nh�n vi�n kh�ng t?n t?i' AS ErrorMessage
        RETURN
    END
    
    -- Ki?m tra xem sohdn ?� t?n t?i trong b?ng Nhap hay ch?a
    IF EXISTS (SELECT * FROM Nhap WHERE sohdn = @sohdn)
    BEGIN
        -- N?u ?� t?n t?i, c?p nh?t b?ng Nhap theo sohdn
        UPDATE Nhap
        SET masp = @masp,
            manv = @manv,
            ngaynhap = @ngaynhap,
            soluongN = @soluongN,
            dongiaN = @dongiaN
        WHERE sohdn = @sohdn
        
        -- Tr? v? m� l?i 0
        SELECT 0 AS ErrorCode, 'C?p nh?t d? li?u th�nh c�ng' AS ErrorMessage
        RETURN
    END
    ELSE
    BEGIN
        -- N?u ch?a t?n t?i, th�m m?i b?ng Nhap
        INSERT INTO Nhap (sohdn, masp, manv, ngaynhap, soluongN, dongiaN)
        VALUES (@sohdn, @masp, @manv, @ngaynhap, @soluongN, @dongiaN)
        
        -- Tr? v? m� l?i 0
        SELECT 0 AS ErrorCode, 'Th�m m?i d? li?u th�nh c�ng' AS ErrorMessage
        RETURN
    END
END

--C�u 7 
CREATE PROCEDURE lab8_c7
    @sohdx INT,
    @masp INT,
    @manv INT,
    @ngayxuat DATE,
    @soluongX INT
AS
BEGIN
    IF NOT EXISTS(SELECT * FROM Sanpham WHERE masp = @masp)
    BEGIN
        RETURN 1 
    END
    
    IF NOT EXISTS(SELECT * FROM Nhanvien WHERE manv = @manv)
    BEGIN
        RETURN 2
    END
    
    IF @soluongX > (SELECT soluong FROM Sanpham WHERE masp = @masp)
    BEGIN
        RETURN 3 
    END

    IF EXISTS(SELECT * FROM Xuat WHERE sohdx = @sohdx)
    BEGIN
        UPDATE Xuat
        SET masp = @masp,
            manv = @manv,
            ngayxuat = @ngayxuat,
            soluongX = @soluongX
        WHERE sohdx = @sohdx
    END
    ELSE
    BEGIN
        INSERT INTO Xuat(sohdx, masp, manv, ngayxuat, soluongX)
        VALUES(@sohdx, @masp, @manv, @ngayxuat, @soluongX)
    END
    
    RETURN 0
END