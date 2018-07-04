import { hot } from 'react-hot-loader';

import React from 'react';

import fetch from 'util/fetch';

interface StatusBadgeProps {
  endpoint: string;
}

interface StatusBadgeState {
  loading: boolean;
  error: boolean;
  status: Status;
}

enum Status {
  pending = 'pending',
  running = 'running',
  dead = 'dead',
  notDeployed = 'not-deployed',
  unknown = 'unknown',
}

class StatusBadge extends React.Component<StatusBadgeProps, StatusBadgeState> {
  public state = {
    error: false,
    loading: true,
    status: Status.unknown,
  };

  public componentDidMount() {
    this.fetchData();
  }

  public render() {
    if (this.state.loading) return null;

    return (
      <span className={ `badge ${ this.badgeType }` }>
        { this.statusText }
      </span>
    );
  }

  private get statusText() {
    if (this.state.loading) return 'Checking status…';
    if (this.state.error) return 'Could not contact Nomad';

    switch (this.state.status) {
    case Status.pending: return 'pending';
    case Status.running: return 'running';
    case Status.dead: return 'dead';
    case Status.notDeployed: return 'not deployed';
    default: return 'unknown';
    }
  }

  private get badgeType() {
    if (this.state.loading) return 'badge-secondary';
    if (this.state.error) return 'badge-danger';

    switch (this.state.status) {
    case Status.running: return 'badge-success';
    case Status.pending: return 'badge-warning';
    case Status.dead: return 'badge-secondary';
    case Status.notDeployed: return 'badge-secondary';
    }
  }

  private async fetchData() {
    try {
      const data = await fetch(this.props.endpoint);
      const json = await data.json();

      let status = Status.unknown;

      switch (json.status) {
        case 'pending':
          status = Status.pending;
          break;
        case 'running':
          status = Status.running;
          break;
        case 'dead':
          status = Status.dead;
          break;
        case 'not-deployed':
          status = Status.notDeployed;
          break;
      }

      this.setState({ loading: false, status });
    } catch (_) {
      this.setState({ loading: false, error: true });
    }
  }
}

export default hot(module)(StatusBadge);
