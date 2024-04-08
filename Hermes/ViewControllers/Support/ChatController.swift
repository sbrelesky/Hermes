//
//  ChatController.swift
//  Hermes
//
//  Created by Shane on 3/25/24.
//

import Foundation
import UIKit
import SnapKit
import FirebaseFirestore

class ChatController: BaseViewController {
    
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        
        cv.dataSource = self
        cv.delegate = self
        cv.register(MessageCell.self, forCellWithReuseIdentifier: "cell")
        
        return cv
    }()
    
    lazy var inputBar: MessageInputView =  {
        let v = MessageInputView(frame: .zero)
        v.delegate = self
        return v
    }()
 
    
    let support: Support
    private var messageListener: ListenerRegistration?
    
    var inputBarBottom: Constraint?
    
    init(support: Support) {
        self.support = support
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hidesKeyboardOnTap()
        
        title = "Chat"
        
        // Register for keyboard notifications
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        setupViews()
        
        // Start listening for messages        
        messageListener = SupportManager.shared.fetchChatForSupportTicket(support: support) { error in
            if let error = error {
                self.presentError(error: error)
            } else {
                SupportManager.shared.markReadMessagesForSupport(self.support) { error in
                    print("Error Marking Messages: ", error)
                }
                
                print("Support Chat Pulled")
                
                DispatchQueue.main.async {
                    self.collectionView.reloadData()
                    self.scrollToBottom()
                }
            }
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Stop listening for messages when the view disappears
        messageListener?.remove()
    }
    
    func setupViews() {
        view.addSubview(inputBar)
        view.addSubview(collectionView)
        
        inputBar.snp.makeConstraints { make in
            inputBarBottom = make.bottom.equalTo(view.safeAreaLayoutGuide).constraint
            make.leading.trailing.equalTo(view.safeAreaLayoutGuide)
            make.height.equalTo(60)
        }
        
        
        collectionView.snp.makeConstraints { make in
            make.top.leading.trailing.equalTo(view.safeAreaLayoutGuide)
            make.bottom.equalTo(inputBar.snp.top).offset(-20)
        }
    }
    
    // MARK: - Keyboard Handling
       
    @objc private func keyboardWillShow(_ notification: Notification) {
        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else {
           return
        }
       
        let keyboardHeight = keyboardFrame.height
    
        UIView.animate(withDuration: 0.4, delay: 0.0) {
            self.inputBarBottom?.update(offset: -keyboardHeight)
            self.view.layoutIfNeeded()
        } completion: { _ in
            self.scrollToBottom()
        }
    }
   
    @objc private func keyboardWillHide(_ notification: Notification) {
        UIView.animate(withDuration: 0.4) {
            self.inputBarBottom?.update(offset: 0)
            self.view.layoutIfNeeded()
        }
    }
   
    // MARK: - Message Handling
   
    private func sendChatMessage(message: ChatMessage) {
       // Implement logic to send message to Firestore
        guard let supportId = support.id else { return }
        SupportManager.shared.sendChatMessage(supportId: supportId, message: message) { error in
            if let error = error {
                self.presentError(error: error)
            } else {
                print("Successfully sent message")
            }
        }
    }

   
    // MARK: - Helper Methods
    
    private func scrollToBottom() {
        
        let numberOfItems = collectionView.numberOfItems(inSection: 0)

        if numberOfItems > 0 {
            // Calculate the index path of the last item
            let lastItemIndexPath = IndexPath(item: numberOfItems - 1, section: 0)

            // Scroll to the last item
            collectionView.scrollToItem(at: lastItemIndexPath, at: .bottom, animated: true)
        }
    }
   
    @objc private func dismissKeyboard() {
       view.endEditing(true)
    }
}

extension ChatController: MessageInputDelegate {
    func sendMessage(text: String) {
        guard let uid = UserManager.shared.currentUser?.id else { return }
        
        sendChatMessage(message: ChatMessage(senderId: uid, text: text, timestamp: Timestamp()))
    }
}

extension ChatController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return support.chat?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! MessageCell
        
        if let message = support.chat?[indexPath.item] {
            cell.chatMessage = message
        }
       
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if let message = support.chat?[indexPath.item] {
            let messageWidth = collectionView.bounds.width * 0.7 // Adjust message width as needed
            
            // Calculate height of message text based on its content and width
            let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
            let estimatedFrame = NSString(string: message.text).boundingRect(with: CGSize(width: messageWidth, height: .infinity), options: options, attributes: [NSAttributedString.Key.font: ThemeManager.Font.Style.secondary(weight: .regular).font], context: nil)
            
            // Add padding to estimatedFrame height for better appearance
            let cellHeight = estimatedFrame.height + 20 // Adjust padding as needed
            
            return CGSize(width: collectionView.bounds.width, height: cellHeight)
        }
        
        return .zero
    }
}

