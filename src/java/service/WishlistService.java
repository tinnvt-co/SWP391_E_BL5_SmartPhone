/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package service;

import DAO.WishlistDAO;
import DTO.WishlistViewDTO;
import com.mysql.cj.jdbc.exceptions.NotUpdatable;
import exception.DuplicateException;
import exception.NotFoundException;
import java.sql.SQLException;
import java.util.List;
/**
 *
 * @author admin
 */
public class WishlistService {
    private final WishlistDAO wishlistDao = new WishlistDAO();
    
    public WishlistService() {
    }
    
    public List<WishlistViewDTO> view(int userId)throws SQLException{
        return wishlistDao.findByUserId(userId);
    }
    
    public void insert(int userId, int productVariantId)throws SQLException{
        if(wishlistDao.exists(userId, productVariantId)){
            throw new DuplicateException("Sản phẩm đã có trong yêu thích");
        }
        wishlistDao.insert(userId, productVariantId);
    }
    
    public void delete(int userId, int productVariantId) throws SQLException{
        if(!wishlistDao.exists(userId, productVariantId)){
            throw new NotFoundException("Không tìm thấy trong yêu thích");
        }
        wishlistDao.delete(userId, productVariantId);
    }
}
