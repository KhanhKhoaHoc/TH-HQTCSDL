Go
use QuanLyBanHang
Go

--Câu 1--
Go
CREATE FUNCTION fn_C1 (@masp VARCHAR(50))
RETURNS VARCHAR(50)
AS
BEGIN
    DECLARE @hangsx VARCHAR(50)
    SELECT @hangsx = h.Tenhang
    FROM Sanpham s
    JOIN Hangsx h ON s.mahangsx = h.mahangsx
    WHERE s.masp = @masp

    RETURN @hangsx
END
Go
Go
SELECT dbo.fn_C1('SP01')
Go

--Câu 2--
Go
CREATE FUNCTION fn_C2(@x INT, @y INT)
RETURNS MONEY
AS
BEGIN
    DECLARE @TongGiaTriNhap MONEY
    SELECT @TongGiaTriNhap = SUM(dongiaN * soluongN)
    FROM Nhap
    WHERE YEAR(ngaynhap) BETWEEN @x AND @y
    RETURN @TongGiaTriNhap
END
Go
Go
SELECT dbo.fn_C2(2016,2019)
Go


--Câu 3--
Go 
CREATE FUNCTION fn_C3(@tenSanPham nvarchar(50), @nam int)
RETURNS int
AS
BEGIN
    DECLARE @soLuongNhap int, @soLuongXuat int, @soLuongThayDoi int;
    SELECT @soLuongNhap = SUM(soluongN) FROM Nhap n JOIN Sanpham sp ON n.masp = sp.masp WHERE sp.tensp = @tenSanPham AND YEAR(n.ngaynhap) = @nam;
    SELECT @soLuongXuat = SUM(soluongX) FROM Xuat x JOIN Sanpham sp ON x.masp = sp.masp WHERE sp.tensp = @tenSanPham AND YEAR(x.ngayxuat) = @nam;
    SET @soLuongThayDoi = @soLuongNhap - @soLuongXuat;
    RETURN @soLuongThayDoi;
END
Go
Go
SELECT dbo.fn_C3('Galaxy Note 11',2020)
Go

--Câu 4--
Go
CREATE FUNCTION dbo.fn_C4(
    @ngay_bat_dau DATE,
    @ngay_ket_thuc DATE
)
RETURNS MONEY
AS
BEGIN
    DECLARE @tong_gia_tri_nhap MONEY;
    SELECT @tong_gia_tri_nhap = SUM(nhap.soluongN * sanpham.giaban)
    FROM Nhap AS nhap
    INNER JOIN Sanpham AS sanpham ON nhap.masp = sanpham.masp
    WHERE nhap.ngaynhap >= @ngay_bat_dau AND nhap.ngaynhap <= @ngay_ket_thuc;
    RETURN @tong_gia_tri_nhap;
END;
Go
Go
SELECT dbo.fn_C4('2018-01-01', '2020-12-31') AS TongGiaTriNhap;
Go

--Câu 5--
Go
CREATE FUNCTION fn_C5(@tenHang NVARCHAR(20), @nam INT)
RETURNS MONEY
AS
BEGIN
  DECLARE @tongGiaTriXuat MONEY;
  SELECT @tongGiaTriXuat = SUM(S.giaban * X.soluongX)
  FROM Xuat X
  JOIN Sanpham S ON X.masp = S.masp
  JOIN Hangsx H ON S.mahangsx = H.mahangsx
  WHERE H.tenhang = @tenHang AND YEAR(X.ngayxuat) = @nam;
  RETURN @tongGiaTriXuat;
END;
Go
Go
SELECT dbo.fn_C5(N'Samsung', 2020) AS 'TongGiaTriXuat';
Go

--Câu 6--
Go
CREATE FUNCTION fn_C6 (@tenPhong NVARCHAR(30))
RETURNS TABLE
AS
RETURN
    SELECT phong, COUNT(manv) AS soLuongNhanVien
    FROM Nhanvien
    WHERE phong = @tenPhong
    GROUP BY phong;
Go
Go
SELECT * FROM fn_C6(N'K? toán')
Go

--Câu 7--
Go
CREATE FUNCTION fn_C7(@ten_sp NVARCHAR(20), @ngay_xuat DATE)
RETURNS INT
AS
BEGIN
  DECLARE @so_luong_xuat INT
  SELECT @so_luong_xuat = SUM(soluongX)
  FROM Xuat x JOIN Sanpham sp ON x.masp = sp.masp
  WHERE sp.tensp = @ten_sp AND x.ngayxuat = @ngay_xuat
  RETURN @so_luong_xuat
END
Go
Go
SELECT dbo.fn_C7('OPPO', '2020-06-14')
Go

--Câu 8--
Go
CREATE FUNCTION fn_C8 (@sohdx NCHAR(10))
RETURNS NVARCHAR(20)
AS
BEGIN
  DECLARE @sdt NVARCHAR(20)
  SELECT @sdt = Nhanvien.sodt
  FROM Nhanvien
  INNER JOIN Xuat ON Nhanvien.manv = Xuat.manv
  WHERE Xuat.sohdx = @sohdx
  RETURN @sdt
END
Go
Go
SELECT dbo.fn_C8('X02')
Go

--Câu 9--
Go
CREATE FUNCTION fn_C9(@tenSP NVARCHAR(20), @nam INT)
RETURNS INT
AS
BEGIN
  DECLARE @tongNhapXuat INT;
  SET @tongNhapXuat = (
  SELECT COALESCE(SUM(nhap.soluongN), 0) + COALESCE(SUM(xuat.soluongX), 0) AS tongSoLuong
    FROM Sanpham sp
    LEFT JOIN Nhap nhap ON sp.masp = nhap.masp
    LEFT JOIN Xuat xuat ON sp.masp = xuat.masp
    WHERE sp.tensp = @tenSP AND YEAR(nhap.ngaynhap) = @nam AND YEAR(xuat.ngayxuat) = @nam
  );
  RETURN @tongNhapXuat;
END;
Go
Go
SELECT dbo.fn_C9('Galaxy V21', 2020) AS TongNhapXuat;
Go

--Câu 10--
Go
CREATE FUNCTION fn_C10(@tenhang NVARCHAR(20))
RETURNS INT
AS
BEGIN
    DECLARE @soluong INT;

    SELECT @soluong = SUM(soluong)
    FROM Sanpham sp JOIN Hangsx hs ON sp.mahangsx = hs.mahangsx
    WHERE hs.tenhang = @tenhang;

    RETURN @soluong;
END;
Go
Go
SELECT dbo.fn_C10('OPPO') AS 'T?ng s? l??ng s?n ph?m c?a hãng'
Go