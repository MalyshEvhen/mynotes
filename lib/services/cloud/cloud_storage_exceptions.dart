class CloudStorageException implements Exception {
  const CloudStorageException();
}

class CouldNoteCreateNoteException extends CloudStorageException {}

class CouldNotGetAllNotesException extends CloudStorageException {}

class CouldNoteUpdateNoteException extends CloudStorageException {}

class CouldNoteDeleteNoteException extends CloudStorageException {}
