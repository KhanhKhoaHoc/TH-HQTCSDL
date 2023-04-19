--C�u 1
CREATE TRIGGER lab9_c1
ON Nhap
AFTER INSERT
AS
BEGIN
    DECLARE @masp NVARCHAR(10)
    DECLARE @manv NVARCHAR(10)
    DECLARE @soluongN INT
    DECLARE @dongiaN FLOAT

    SELECT @masp = masp, @manv = manv, @soluongN = soluongN, @dongiaN = dongiaN
    FROM inserted
    
    -- Ki?m tra masp c� trong b?ng Sanpham ch?a
    IF NOT EXISTS (SELECT * FROM Sanpham WHERE masp = @masp)
    BEGIN
        RAISERROR('L?i: Kh�ng t?n t?i s?n trong danh m?c s?n ph?m', 16, 1)
        ROLLBACK TRANSACTION
        RETURN
    END
    
    -- Ki?m tra manv c� trong b?ng Nhanvien ch?a
    IF NOT EXISTS (SELECT * FROM Nhanvien WHERE manv = @manv)
    BEGIN
        RAISERROR('L?i: Kh�ng t?n t?i nhan vi�n', 16, 1)
        ROLLBACK TRANSACTION
        RETURN
    END
    
    -- Ki?m tra r�ng bu?c d? li?u
    IF @soluongN <= 0 OR @dongiaN <= 0
    BEGIN
        RAISERROR('L?i: soluongN v� dongiaN ph?i l?n h?n 0', 16, 1)
        ROLLBACK TRANSACTION
        RETURN
    END
    
    -- C?p nh?t s? l??ng s?n ph?m trong b?ng Sanpham
    UPDATE Sanpham
    SET soluong = soluong + @soluongN
    WHERE masp = @masp
END

--C�u 2
-----c�u 1-------

CREATE TRIGGER Lab9_Cau1
ON Nhap
AFTER INSERT
AS
BEGIN
    DECLARE @masp NVARCHAR(10)
    DECLARE @manv NVARCHAR(10)
    DECLARE @soluongN INT
    DECLARE @dongiaN FLOAT

    SELECT @masp = masp, @manv = manv, @soluongN = soluongN, @dongiaN = dongiaN
    FROM inserted
    
    -- Ki?m tra masp c� trong b?ng Sanpham ch?a
    IF NOT EXISTS (SELECT * FROM Sanpham WHERE masp = @masp)
    BEGIN
        RAISERROR('L?i: Kh�ng t?n t?i s?n trong danh m?c s?n ph?m', 16, 1)
        ROLLBACK TRANSACTION
        RETURN
    END
    
    -- Ki?m tra manv c� trong b?ng Nhanvien ch?a
    IF NOT EXISTS (SELECT * FROM Nhanvien WHERE manv = @manv)
    BEGIN
        RAISERROR('L?i: Kh�ng t?n t?i nhan vi�n', 16, 1)
        ROLLBACK TRANSACTION
        RETURN
    END
    
    -- Ki?m tra r�ng bu?c d? li?u
    IF @soluongN <= 0 OR @dongiaN <= 0
    BEGIN
        RAISERROR('L?i: soluongN v� dongiaN ph?i l?n h?n 0', 16, 1)
        ROLLBACK TRANSACTION
        RETURN
    END
    
    -- C?p nh?t s? l??ng s?n ph?m trong b?ng Sanpham
    UPDATE Sanpham
    SET soluong = soluong + @soluongN
    WHERE masp = @masp
END

go


--c�u 2
CREATE TRIGGER lab9_c2
ON Xuat
AFTER INSERT
AS
BEGIN
    -- Ki?m tra r�ng bu?c to�n v?n
    IF NOT EXISTS (SELECT masp FROM Sanpham WHERE masp = (SELECT masp FROM inserted))
    BEGIN
        RAISERROR('M� s?n ph?m kh�ng t?n t?i trong b?ng Sanpham', 16, 1)
        ROLLBACK TRANSACTION
        RETURN
    END

    IF NOT EXISTS (SELECT manv FROM Nhanvien WHERE manv = (SELECT manv FROM inserted))
    BEGIN
        RAISERROR('M� nh�n vi�n kh�ng t?n t?i trong b?ng Nhanvien', 16, 1)
        ROLLBACK TRANSACTION
        RETURN
    END
    
    -- Ki?m tra r�ng bu?c d? li?u
    DECLARE @soluongX INT
    SELECT @soluongX = soluongX FROM inserted
    
    DECLARE @soluong INT
    SELECT @soluong = soluong FROM Sanpham WHERE masp = (SELECT masp FROM inserted)
    
    IF (@soluongX > @soluong)
    BEGIN
        RAISERROR('S? l??ng xu?t v??t qu� s? l??ng trong kho', 16, 1)
        ROLLBACK TRANSACTION
        RETURN
    END
    
    -- C?p nh?t s? l??ng trong b?ng Sanpham
    UPDATE Sanpham
    SET soluong = soluong - @soluongX
    WHERE masp = (SELECT masp FROM inserted)
END



--c�u 3
CREATE TRIGGER lab9_c3
ON Xuat
AFTER DELETE
AS
BEGIN
    -- C?p nh?t s? l??ng h�ng trong b?ng Sanpham t??ng ?ng v?i s?n ph?m ?� xu?t
    UPDATE Sanpham
    SET Soluong = Sanpham.Soluong + deleted.soluongX
    FROM Sanpham
    JOIN deleted ON Sanpham.Masp = deleted.Masp
END


--c�u 4
CREATE TRIGGER lab9_c4
ON xuat
AFTER UPDATE
AS
BEGIN
    -- Ki?m tra xem c� �t nh?t 2 b?n ghi b? update hay kh�ng
    IF (SELECT COUNT(*) FROM inserted) < 2
    BEGIN
        DECLARE @old_soluong INT, @new_soluong INT, @masp NVARCHAR(10)
SELECT @masp = i.masp, @old_soluong = d.soluongX, @new_soluong = i.soluongX
        FROM deleted d INNER JOIN inserted i ON d.sohdx = i.sohdx AND d.masp = i.masp

        -- Ki?m tra s? l??ng xu?t m?i c� nh? h?n s? l??ng t?n kho hay kh�ng
        IF (@new_soluong <= (SELECT soluong FROM sanpham WHERE masp = @masp))
        BEGIN
            UPDATE xuat SET soluongX = @new_soluong WHERE sohdx IN (SELECT sohdx FROM inserted)
            UPDATE sanpham SET soluong = soluong + @old_soluong - @new_soluong WHERE masp = @masp
        END
    END
END

--c�u 5
CREATE TRIGGER lab9_c5
ON Nhap
AFTER UPDATE
AS
BEGIN
    -- Ki?m tra s? b?n ghi thay ??i
    IF (SELECT COUNT(*) FROM inserted) > 1
    BEGIN
        RAISERROR('Ch? ???c ph�p c?p nh?t 1 b?n ghi t?i m?t th?i ?i?m', 16, 1)
        ROLLBACK
    END
    
    -- Ki?m tra s? l??ng nh?p
    DECLARE @masp INT
    DECLARE @soluongN INT
    DECLARE @soluong INT
    
    SELECT @masp = i.masp, @soluongN = i.soluongN, @soluong = s.soluong
    FROM inserted i
    INNER JOIN Sanpham s ON i.masp = s.masp
    
    
    
    -- C?p nh?t s? l??ng trong b?ng Sanpham
    UPDATE Sanpham
    SET soluong = soluong + (@soluongN - (SELECT soluongN FROM deleted WHERE masp = @masp))
    WHERE masp = @masp
END

--c�u 6
CREATE TRIGGER lab9_c6
ON Nhap
AFTER DELETE
AS

BEGIN
    
    UPDATE Sanpham
    SET Soluong = Sanpham.Soluong - deleted.soluongN
    FROM Sanpham
    JOIN deleted ON Sanpham.Masp = deleted.Masp
END
