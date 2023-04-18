//
//  MainViewController.swift
//  TestPhotoGetPost
//
//  Created by Александр Молчан on 18.04.23.
//

import UIKit
import SnapKit

final class MainViewController: UIViewController {
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        return tableView
    }()
    
    private lazy var spinner: UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView(style: .large)
        spinner.color = .magenta
        return spinner
    }()
    
    private lazy var refreshControl: UIRefreshControl = {
        let refresh = UIRefreshControl()
        refresh.tintColor = .magenta
        return refresh
    }()
    
    private lazy var photoPicker: UIImagePickerController = {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .camera
        return picker
    }()
    
    private var currentPage = 0
    private var totalPages = 0
    private var selectedIndex: IndexPath?
    
    private var photoArray = [PhotoObject]() {
        didSet {
            tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        controllerConfiguration()
        getData()
    }
    
    // MARK: -
    // MARK: - Configurations
    
    private func controllerConfiguration() {
        registerCells()
        layoutElements()
        makeConstraints()
        refreshControllConfiguration()
    }
    
    private func registerCells() {
        tableView.register(PhotoCell.self, forCellReuseIdentifier: PhotoCell.id)
    }
    
    private func layoutElements() {
        self.view.addSubview(tableView)
        self.view.addSubview(spinner)
    }
    
    private func makeConstraints() {
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        spinner.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
    
    private func refreshControllConfiguration() {
        tableView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(refreshAction), for: .valueChanged)
    }
    
    // MARK: -
    // MARK: - Business Logic
    
    private func getData() {
        spinner.startAnimating()
        NetworkManager().getPhotosData { [weak self] response in
            self?.currentPage = response.currentPage
            self?.totalPages = response.totalPages
            self?.photoArray = response.photos
            self?.spinner.stopAnimating()
        } failure: { [weak self] error in
            self?.showAlert(title: "Network Error!", message: "Please, try again later.")
            self?.spinner.stopAnimating()
            print(error)
        }
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okButton = UIAlertAction(title: "Ok", style: .default)
        alert.addAction(okButton)
        present(alert, animated: true)
    }
    
    private func getNextPageData() {
        let nextPage = currentPage + 1
        if currentPage < totalPages {
            spinner.startAnimating()
            NetworkManager().getPhotosData(page: nextPage) { [weak self] response in
                self?.currentPage = response.currentPage
                self?.photoArray.append(contentsOf: response.photos)
                self?.spinner.stopAnimating()
            } failure: { [weak self] error in
                self?.spinner.stopAnimating()
                print(error)
            }
        }
    }
    
    @objc private func refreshAction() {
        getData()
        refreshControl.endRefreshing()
    }
    
    private func showPicker(at indexPath: IndexPath) {
        present(photoPicker, animated: true)
        self.selectedIndex = indexPath
    }
    
}

// MARK: -
// MARK: - TableView DataSourse Extencion

extension MainViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        photoArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        PhotoCell(currentPhoto: photoArray[indexPath.row])
    }
    
}

// MARK: -
// MARK: - TableView Delegate Extencion

extension MainViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        showPicker(at: indexPath)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == photoArray.count - 1 {
            getNextPageData()
        }
    }
    
}

// MARK: -
// MARK: - ImagePicker Extencion

extension MainViewController: UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage,
              let index = selectedIndex?.row else { return }
        let name = "Developer Alexander Molchan"
        let photo = image.jpegData(compressionQuality: 0.5) ?? Data()
        
        let postedPhoto = PostedPhoto(name: name, photo: photo, typeId: String(index))
        
        NetworkManager().uploadPhoto(photo: postedPhoto) {
            self.showAlert(title: "Upload successful!", message: "Congratulations!")
        } failure: {
            self.showAlert(title: "Upload Error!", message: "Please, try again later.")
        }
        
        picker.dismiss(animated: true)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
    
}


