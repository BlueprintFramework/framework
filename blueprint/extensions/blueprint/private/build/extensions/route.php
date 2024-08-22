Route::group(['prefix' => 'extensions/[id]'], function () {
    Route::get('/', [Admin\Extensions\[id]\[id]ExtensionController::class, 'index'])->name('admin.extensions.[id].index');
    Route::patch('/', [Admin\Extensions\[id]\[id]ExtensionController::class, 'update'])->name('admin.extensions.[id].patch');
    Route::post('/', [Admin\Extensions\[id]\[id]ExtensionController::class, 'post'])->name('admin.extensions.[id].post');
    Route::put('/', [Admin\Extensions\[id]\[id]ExtensionController::class, 'put'])->name('admin.extensions.[id].put');
    Route::delete('/{target}/{id}', [Admin\Extensions\[id]\[id]ExtensionController::class, 'delete'])->name('admin.extensions.[id].delete');
});