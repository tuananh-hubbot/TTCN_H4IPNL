import { Component, inject, signal } from '@angular/core';
import { HttpClient } from '@angular/common/http';

interface HealthResponse {
  status: string;
  application: string;
}

@Component({
  selector: 'app-root',
  standalone: true,
  templateUrl: './app.component.html',
})
export class AppComponent {
  private readonly http = inject(HttpClient);
  readonly apiStatus = signal('Chưa kiểm tra');

  checkApi(): void {
    this.apiStatus.set('Đang kết nối...');
    this.http.get<HealthResponse>('/api/health').subscribe({
      next: result => this.apiStatus.set(`${result.application}: ${result.status}`),
      error: () => this.apiStatus.set('Không kết nối được backend'),
    });
  }
}
