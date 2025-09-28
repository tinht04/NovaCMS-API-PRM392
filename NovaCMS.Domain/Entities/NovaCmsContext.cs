using System;
using System.Collections.Generic;
using Microsoft.EntityFrameworkCore;
using Pomelo.EntityFrameworkCore.MySql.Scaffolding.Internal;

namespace NovaCMS.Domain.Entities;

public partial class NovaCmsContext : DbContext
{
    public NovaCmsContext()
    {
    }

    public NovaCmsContext(DbContextOptions<NovaCmsContext> options)
        : base(options)
    {
    }

    public virtual DbSet<BlogPost> BlogPosts { get; set; }

    public virtual DbSet<BlogPostImage> BlogPostImages { get; set; }

    public virtual DbSet<Category> Categories { get; set; }

    public virtual DbSet<Equipment> Equipments { get; set; }

    public virtual DbSet<EquipmentImage> EquipmentImages { get; set; }

    public virtual DbSet<EquipmentItem> EquipmentItems { get; set; }

    public virtual DbSet<Invoice> Invoices { get; set; }

    public virtual DbSet<RentalOrder> RentalOrders { get; set; }

    public virtual DbSet<RentalOrderDetail> RentalOrderDetails { get; set; }

    public virtual DbSet<Role> Roles { get; set; }

    public virtual DbSet<User> Users { get; set; }

    protected override void OnConfiguring(DbContextOptionsBuilder optionsBuilder)
#warning To protect potentially sensitive information in your connection string, you should move it out of source code. You can avoid scaffolding the connection string by using the Name= syntax to read it from configuration - see https://go.microsoft.com/fwlink/?linkid=2131148. For more guidance on storing connection strings, see https://go.microsoft.com/fwlink/?LinkId=723263.
        => optionsBuilder.UseMySql("server=mysql-2baa9010-cin04pc-3f36.d.aivencloud.com;port=21015;database=NovaCMS;user=avnadmin;password=AVNS_c1hESNdanvUTE_9h6mM", Microsoft.EntityFrameworkCore.ServerVersion.Parse("8.0.35-mysql"));

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        modelBuilder
            .UseCollation("utf8mb4_0900_ai_ci")
            .HasCharSet("utf8mb4");

        modelBuilder.Entity<BlogPost>(entity =>
        {
            entity.HasKey(e => e.PostId).HasName("PRIMARY");

            entity.HasIndex(e => e.AuthorId, "AuthorId");

            entity.Property(e => e.Content).HasColumnType("text");
            entity.Property(e => e.CreatedAt)
                .HasDefaultValueSql("now()")
                .HasColumnType("datetime");
            entity.Property(e => e.Location).HasMaxLength(255);
            entity.Property(e => e.PricePerDay).HasPrecision(10, 2);
            entity.Property(e => e.Status)
                .HasDefaultValueSql("'Draft'")
                .HasColumnType("enum('Draft','Published','Archived')");
            entity.Property(e => e.Title).HasMaxLength(255);
            entity.Property(e => e.UpdatedAt)
                .ValueGeneratedOnAddOrUpdate()
                .HasDefaultValueSql("now()")
                .HasColumnType("datetime");

            entity.HasOne(d => d.Author).WithMany(p => p.BlogPosts)
                .HasForeignKey(d => d.AuthorId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("BlogPosts_ibfk_1");
        });

        modelBuilder.Entity<BlogPostImage>(entity =>
        {
            entity.HasKey(e => e.ImageId).HasName("PRIMARY");

            entity.HasIndex(e => e.PostId, "PostId");

            entity.Property(e => e.ImageUrl).HasMaxLength(500);
            entity.Property(e => e.IsPrimary).HasDefaultValueSql("'0'");
            entity.Property(e => e.SortOrder).HasDefaultValueSql("'0'");

            entity.HasOne(d => d.Post).WithMany(p => p.BlogPostImages)
                .HasForeignKey(d => d.PostId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("BlogPostImages_ibfk_1");
        });

        modelBuilder.Entity<Category>(entity =>
        {
            entity.HasKey(e => e.CategoryId).HasName("PRIMARY");

            entity.HasIndex(e => e.CategoryName, "CategoryName").IsUnique();

            entity.Property(e => e.CategoryName).HasMaxLength(100);
            entity.Property(e => e.Description).HasColumnType("text");
        });

        modelBuilder.Entity<Equipment>(entity =>
        {
            entity.HasKey(e => e.EquipmentId).HasName("PRIMARY");

            entity.HasIndex(e => e.CategoryId, "CategoryId");

            entity.Property(e => e.Brand).HasMaxLength(100);
            entity.Property(e => e.ConditionNote).HasMaxLength(255);
            entity.Property(e => e.DepositFee)
                .HasPrecision(10, 2)
                .HasDefaultValueSql("'0.00'");
            entity.Property(e => e.Description).HasColumnType("text");
            entity.Property(e => e.Name).HasMaxLength(255);
            entity.Property(e => e.PricePerDay).HasPrecision(10, 2);
            entity.Property(e => e.Status)
                .HasDefaultValueSql("'Active'")
                .HasColumnType("enum('Active','Inactive')");
            entity.Property(e => e.Stock).HasDefaultValueSql("'1'");

            entity.HasOne(d => d.Category).WithMany(p => p.Equipment)
                .HasForeignKey(d => d.CategoryId)
                .HasConstraintName("Equipments_ibfk_1");
        });

        modelBuilder.Entity<EquipmentImage>(entity =>
        {
            entity.HasKey(e => e.ImageId).HasName("PRIMARY");

            entity.HasIndex(e => e.EquipmentId, "EquipmentId");

            entity.Property(e => e.ImageUrl).HasMaxLength(500);
            entity.Property(e => e.IsPrimary).HasDefaultValueSql("'0'");
            entity.Property(e => e.SortOrder).HasDefaultValueSql("'0'");

            entity.HasOne(d => d.Equipment).WithMany(p => p.EquipmentImages)
                .HasForeignKey(d => d.EquipmentId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("EquipmentImages_ibfk_1");
        });

        modelBuilder.Entity<EquipmentItem>(entity =>
        {
            entity.HasKey(e => e.ItemId).HasName("PRIMARY");

            entity.HasIndex(e => e.EquipmentId, "EquipmentId");

            entity.HasIndex(e => e.SerialNumber, "SerialNumber").IsUnique();

            entity.Property(e => e.ConditionNote).HasMaxLength(255);
            entity.Property(e => e.SerialNumber).HasMaxLength(100);
            entity.Property(e => e.Status)
                .HasDefaultValueSql("'Available'")
                .HasColumnType("enum('Available','Held','Rented','Maintenance','Lost')");

            entity.HasOne(d => d.Equipment).WithMany(p => p.EquipmentItems)
                .HasForeignKey(d => d.EquipmentId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("EquipmentItems_ibfk_1");
        });

        modelBuilder.Entity<Invoice>(entity =>
        {
            entity.HasKey(e => e.InvoiceId).HasName("PRIMARY");

            entity.HasIndex(e => e.CreatedByStaffId, "CreatedByStaffId");

            entity.HasIndex(e => e.OrderId, "OrderId");

            entity.Property(e => e.Amount).HasPrecision(10, 2);
            entity.Property(e => e.DueDate).HasColumnType("datetime");
            entity.Property(e => e.InvoiceDate)
                .HasDefaultValueSql("now()")
                .HasColumnType("datetime");
            entity.Property(e => e.PaymentMethod)
                .HasDefaultValueSql("'Cash'")
                .HasColumnType("enum('Cash','BankTransfer','Momo','ZaloPay')");
            entity.Property(e => e.PaymentStatus)
                .HasDefaultValueSql("'Unpaid'")
                .HasColumnType("enum('Unpaid','Paid','Refunded')");

            entity.HasOne(d => d.CreatedByStaff).WithMany(p => p.Invoices)
                .HasForeignKey(d => d.CreatedByStaffId)
                .HasConstraintName("Invoices_ibfk_2");

            entity.HasOne(d => d.Order).WithMany(p => p.Invoices)
                .HasForeignKey(d => d.OrderId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("Invoices_ibfk_1");
        });

        modelBuilder.Entity<RentalOrder>(entity =>
        {
            entity.HasKey(e => e.OrderId).HasName("PRIMARY");

            entity.HasIndex(e => e.UserId, "UserId");

            entity.Property(e => e.Note).HasMaxLength(500);
            entity.Property(e => e.OrderDate)
                .HasDefaultValueSql("now()")
                .HasColumnType("datetime");
            entity.Property(e => e.ReferenceNo).HasMaxLength(100);
            entity.Property(e => e.Status)
                .HasDefaultValueSql("'Pending'")
                .HasColumnType("enum('Pending','Confirmed','Rented','Cancelled','Completed')");
            entity.Property(e => e.TotalAmount).HasPrecision(10, 2);

            entity.HasOne(d => d.User).WithMany(p => p.RentalOrders)
                .HasForeignKey(d => d.UserId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("RentalOrders_ibfk_1");
        });

        modelBuilder.Entity<RentalOrderDetail>(entity =>
        {
            entity.HasKey(e => e.OrderDetailId).HasName("PRIMARY");

            entity.HasIndex(e => e.EquipmentId, "EquipmentId");

            entity.HasIndex(e => e.EquipmentItemId, "EquipmentItemId");

            entity.HasIndex(e => e.OrderId, "OrderId");

            entity.Property(e => e.DepositFee)
                .HasPrecision(10, 2)
                .HasDefaultValueSql("'0.00'");
            entity.Property(e => e.OverdueDays).HasDefaultValueSql("'0'");
            entity.Property(e => e.OverdueFee)
                .HasPrecision(10, 2)
                .HasDefaultValueSql("'0.00'");
            entity.Property(e => e.PricePerDay).HasPrecision(10, 2);
            entity.Property(e => e.RentalEndDate).HasColumnType("datetime");
            entity.Property(e => e.RentalStartDate).HasColumnType("datetime");
            entity.Property(e => e.ReturnDate).HasColumnType("datetime");

            entity.HasOne(d => d.Equipment).WithMany(p => p.RentalOrderDetails)
                .HasForeignKey(d => d.EquipmentId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("RentalOrderDetails_ibfk_3");

            entity.HasOne(d => d.EquipmentItem).WithMany(p => p.RentalOrderDetails)
                .HasForeignKey(d => d.EquipmentItemId)
                .HasConstraintName("RentalOrderDetails_ibfk_2");

            entity.HasOne(d => d.Order).WithMany(p => p.RentalOrderDetails)
                .HasForeignKey(d => d.OrderId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("RentalOrderDetails_ibfk_1");
        });

        modelBuilder.Entity<Role>(entity =>
        {
            entity.HasKey(e => e.RoleId).HasName("PRIMARY");

            entity.HasIndex(e => e.RoleName, "RoleName").IsUnique();

            entity.Property(e => e.RoleName).HasMaxLength(50);
        });

        modelBuilder.Entity<User>(entity =>
        {
            entity.HasKey(e => e.UserId).HasName("PRIMARY");

            entity.HasIndex(e => e.Email, "Email").IsUnique();

            entity.HasIndex(e => e.GoogleId, "GoogleId").IsUnique();

            entity.HasIndex(e => e.PhoneNumber, "PhoneNumber").IsUnique();

            entity.HasIndex(e => e.RoleId, "RoleId");

            entity.Property(e => e.Address).HasMaxLength(255);
            entity.Property(e => e.AvatarUrl).HasColumnType("text");
            entity.Property(e => e.CreatedAt)
                .HasDefaultValueSql("now()")
                .HasColumnType("datetime");
            entity.Property(e => e.FullName).HasMaxLength(255);
            entity.Property(e => e.PasswordHash).HasMaxLength(255);
            entity.Property(e => e.PhoneNumber).HasMaxLength(20);
            entity.Property(e => e.RoleId).HasDefaultValueSql("'1'");
            entity.Property(e => e.Status)
                .HasDefaultValueSql("'Active'")
                .HasColumnType("enum('Active','Inactive')");
            entity.Property(e => e.UpdatedAt)
                .ValueGeneratedOnAddOrUpdate()
                .HasDefaultValueSql("now()")
                .HasColumnType("datetime");

            entity.HasOne(d => d.Role).WithMany(p => p.Users)
                .HasForeignKey(d => d.RoleId)
                .HasConstraintName("Users_ibfk_1");
        });

        OnModelCreatingPartial(modelBuilder);
    }

    partial void OnModelCreatingPartial(ModelBuilder modelBuilder);
}
