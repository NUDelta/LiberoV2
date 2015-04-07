rm build/Liberov1.ipa
xcodebuild -scheme Libero -workspace Libero.xcworkspace clean archive -archivePath build/Libero
xcodebuild -exportArchive -exportFormat ipa -archivePath "build/Libero.xcarchive" -exportPath "build/Liberov1.ipa" -exportProvisioningProfile "Delta Libero"
