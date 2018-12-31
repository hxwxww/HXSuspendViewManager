//
//  HXReuseable.swift
//  HXTools
//
//  Created by HongXiangWen on 2018/12/27.
//  Copyright © 2018年 WHX. All rights reserved.
//

import UIKit

// MARK: -  HXReuseable
protocol HXReuseable { }
extension HXReuseable {
    
    /// 重用标识
    static var reuseIdentifier: String {
        return "\(self)"
    }
    
    /// nib
    static var nib: UINib? {
        return UINib(nibName: "\(self)", bundle: nil)
    }
    
    /// nib的路径
    static var nibPath: String? {
        return Bundle.main.path(forResource: "\(self)", ofType: "nib")
    }
    
}

// MARK: -  UITableView
extension UITableViewCell: HXReuseable { }
extension UITableView {
    
    /// 注册cell
    ///
    /// - Parameter cellClass: cellCalss
    func hx_registerCell<T: UITableViewCell>(cellClass: T.Type) {
        if T.nibPath != nil {
            /// 如果有nib，注册nib
            register(T.nib, forCellReuseIdentifier: T.reuseIdentifier)
        } else {
            /// 如果没有nib，注册class
            register(cellClass, forCellReuseIdentifier: T.reuseIdentifier)
        }
    }
    
    /// 从缓存池取出cell，你需要在方法后面添加”as CellClass“来显示的表示你所需要获取的cell的类型，如果不添加，默认为UITableViewCell
    ///
    /// - Parameter indexPath: indexPath
    /// - Returns: 可重用的cell
    func hx_dequeueReusableCell<T: UITableViewCell>(indexPath: IndexPath) -> T {
        guard let cell = dequeueReusableCell(withIdentifier: T.reuseIdentifier, for: indexPath) as? T else {
            fatalError("你还没有注册cell，请先调用“hx_registerCell(cellClass:)”注册cell")
        }
        return cell
    }
    
}

// MARK: -  UICollectionView
extension UICollectionReusableView: HXReuseable { }
extension UICollectionView {
    
    /// 注册cell
    ///
    /// - Parameter cellClass: cellCalss
    func hx_registerCell<T: UICollectionViewCell>(cellClass: T.Type) {
        if T.nibPath != nil {
            /// 如果有nib，注册nib
            register(T.nib, forCellWithReuseIdentifier: T.reuseIdentifier)
        } else {
            /// 如果没有nib，注册class
            register(cellClass, forCellWithReuseIdentifier: T.reuseIdentifier)
        }
    }
    
    /// 从缓存池取出cell，你需要在方法后面添加”as CellClass“来显示的表示你所需要获取的cell的类型，如果不添加，默认为UICollectionViewCell
    ///
    /// - Parameter indexPath: indexPath
    /// - Returns: 可重用的cell
    func hx_dequeueReusableCell<T: UICollectionViewCell>(indexPath: IndexPath) -> T {
        guard let cell = dequeueReusableCell(withReuseIdentifier: T.reuseIdentifier, for: indexPath) as? T else {
            fatalError("你还没有注册cell，请先调用“hx_registerCell(cellClass:)”注册cell")
        }
        return cell
    }
    
    /// 注册头部
    ///
    /// - Parameter reusableViewClass: reusableViewClass
    func hx_registerHeader<T: UICollectionReusableView>(reusableViewClass: T.Type) {
        if T.nibPath != nil {
            /// 如果有nib，注册nib
            register(T.nib, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: T.reuseIdentifier)
        } else {
            /// 如果没有nib，注册class
            register(reusableViewClass, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: T.reuseIdentifier)
        }
    }
    
    /// 从缓存池取出header，你需要在方法后面添加”as CellClass“来显示的表示你所需要获取的header的类型，如果不添加，默认为UICollectionReusableView
    ///
    /// - Parameter indexPath: indexPath
    /// - Returns: 可重用的header
    func hx_dequeueReusableHeader<T: UICollectionReusableView>(indexPath: IndexPath) -> T {
        guard let header = dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: T.reuseIdentifier, for: indexPath) as? T else {
            fatalError("你还没有注册header，请先调用“hx_registerHeader(reusableViewClass:)”注册header")
        }
        return header
    }
    
    /// 注册尾部
    ///
    /// - Parameter reusableViewClass: reusableViewClass
    func hx_registerFooter<T: UICollectionReusableView>(reusableViewClass: T.Type) {
        if T.nibPath != nil {
            /// 如果有nib，注册nib
            register(T.nib, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: T.reuseIdentifier)
        } else {
            /// 如果没有nib，注册class
            register(reusableViewClass, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: T.reuseIdentifier)
        }
    }
    
    /// 获取可重用的尾部
    func hx_dequeueReusableFooter<T: UICollectionReusableView>(indexPath: IndexPath) -> T {
        guard let footer = dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: T.reuseIdentifier, for: indexPath) as? T else {
            fatalError("你还没有注册footer，请先调用“hx_registerFooter(reusableViewClass:)”注册footer")
        }
        return footer
    }
    
}
