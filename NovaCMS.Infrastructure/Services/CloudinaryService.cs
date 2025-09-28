using CloudinaryDotNet;
using CloudinaryDotNet.Actions;
using Microsoft.AspNetCore.Http;
using NovaCMS.Application.Interfaces;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace NovaCMS.Infrastructure.Services
{
    public class CloudinaryService : ICloudinaryService
    {
        private readonly Cloudinary _cloudinary;
        public CloudinaryService(Cloudinary cloudinary)
        {
            _cloudinary = cloudinary;
        }

        public async Task<string> DeleteImageAsync(string publicId)
        {
            var deletionParams = new DeletionParams(publicId);
            var result = await _cloudinary.DestroyAsync(deletionParams);

            if (result.Result == "ok")
                return "Delete successful";
            else
                throw new Exception($"Delete failed: {result.Result}");
        }

        public async Task<string> UploadImageAsync(IFormFile fileImg)
        {
            if (fileImg == null || fileImg.Length == 0)
                throw new ArgumentException("File is not valid");

            using var stream = fileImg.OpenReadStream();
            var uploadParams = new ImageUploadParams
            {
                File = new FileDescription(fileImg.FileName, stream),
                //Transformation = new Transformation().Width(500).Height(750).Crop("fill")
            };

            var uploadResult = await _cloudinary.UploadAsync(uploadParams);
            return uploadResult.SecureUrl.AbsoluteUri;
        }
    }
}
